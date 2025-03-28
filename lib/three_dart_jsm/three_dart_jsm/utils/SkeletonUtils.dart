part of jsm_utils;

class SkeletonUtils {
  static retarget(target, source, [options]) {
    var pos = new Vector3(),
        quat = new Quaternion(),
        scale = new Vector3(),
        bindBoneMatrix = new Matrix4(),
        relativeMatrix = new Matrix4(),
        globalMatrix = new Matrix4();

    options = options ?? {};

    options.preserveMatrix = options.preserveMatrix != null ? options.preserveMatrix : true;
    options.preservePosition = options.preservePosition != null ? options.preservePosition : true;
    options.preserveHipPosition = options.preserveHipPosition != null ? options.preserveHipPosition : false;
    options.useTargetMatrix = options.useTargetMatrix != null ? options.useTargetMatrix : false;
    options.hip = options.hip != null ? options.hip : 'hip';
    options.names = options.names ?? {};

    var sourceBones = source.isObject3D ? source.skeleton.bones : getBones(source),
        bones = target.isObject3D ? target.skeleton.bones : getBones(target);

    var bindBones, bone, name, boneTo, bonesPosition;

    // reset bones

    if (target.isObject3D) {
      target.skeleton.pose();
    } else {
      options.useTargetMatrix = true;
      options.preserveMatrix = false;
    }

    if (options.preservePosition) {
      bonesPosition = [];

      for (var i = 0; i < bones.length; i++) {
        bonesPosition.push(bones[i].position.clone());
      }
    }

    if (options.preserveMatrix) {
      // reset matrix

      target.updateMatrixWorld();

      target.matrixWorld.identity();

      // reset children matrix

      for (var i = 0; i < target.children.length; ++i) {
        target.children[i].updateMatrixWorld(true);
      }
    }

    if (options.offsets) {
      bindBones = [];

      for (var i = 0; i < bones.length; ++i) {
        bone = bones[i];
        name = options.names[bone.name] || bone.name;

        if (options.offsets && options.offsets[name]) {
          bone.matrix.multiply(options.offsets[name]);

          bone.matrix.decompose(bone.position, bone.quaternion, bone.scale);

          bone.updateMatrixWorld();
        }

        bindBones.push(bone.matrixWorld.clone());
      }
    }

    for (var i = 0; i < bones.length; ++i) {
      bone = bones[i];
      name = options.names[bone.name] || bone.name;

      boneTo = getBoneByName(name, sourceBones);

      globalMatrix.copy(bone.matrixWorld);

      if (boneTo) {
        boneTo.updateMatrixWorld();

        if (options.useTargetMatrix) {
          relativeMatrix.copy(boneTo.matrixWorld);
        } else {
          relativeMatrix.copy(target.matrixWorld).invert();
          relativeMatrix.multiply(boneTo.matrixWorld);
        }

        // ignore scale to extract rotation

        scale.setFromMatrixScale(relativeMatrix);
        relativeMatrix.scale(scale.set(1 / scale.x, 1 / scale.y, 1 / scale.z));

        // apply to global matrix

        globalMatrix.makeRotationFromQuaternion(quat.setFromRotationMatrix(relativeMatrix));

        if (target.isObject3D) {
          var boneIndex = bones.indexOf(bone),
              wBindMatrix = bindBones
                  ? bindBones[boneIndex]
                  : bindBoneMatrix.copy(target.skeleton.boneInverses[boneIndex]).invert();

          globalMatrix.multiply(wBindMatrix);
        }

        globalMatrix.copyPosition(relativeMatrix);
      }

      if (bone.parent && bone.parent.isBone) {
        bone.matrix.copy(bone.parent.matrixWorld).invert();
        bone.matrix.multiply(globalMatrix);
      } else {
        bone.matrix.copy(globalMatrix);
      }

      if (options.preserveHipPosition && name == options.hip) {
        bone.matrix.setPosition(pos.set(0, bone.position.y, 0));
      }

      bone.matrix.decompose(bone.position, bone.quaternion, bone.scale);

      bone.updateMatrixWorld();
    }

    if (options.preservePosition) {
      for (var i = 0; i < bones.length; ++i) {
        bone = bones[i];
        name = options.names[bone.name] || bone.name;

        if (name != options.hip) {
          bone.position.copy(bonesPosition[i]);
        }
      }
    }

    if (options.preserveMatrix) {
      // restore matrix

      target.updateMatrixWorld(true);
    }
  }

  static retargetClip(target, source, clip, [options]) {
    options = options ?? {};

    options.useFirstFramePosition = options.useFirstFramePosition != null ? options.useFirstFramePosition : false;
    options.fps = options.fps != null ? options.fps : 30;
    options.names = options.names ?? [];

    if (!source.isObject3D) {
      source = getHelperFromSkeleton(source);
    }

    var numFrames = Math.round(clip.duration * (options.fps / 1000) * 1000),
        delta = 1 / options.fps,
        convertedTracks = <KeyframeTrack>[],
        mixer = new AnimationMixer(source),
        bones = getBones(target.skeleton),
        boneDatas = [];
    var positionOffset, bone, boneTo, boneData, name;

    mixer.clipAction(clip)?.play();
    mixer.update(0);

    source.updateMatrixWorld();

    for (var i = 0; i < numFrames; ++i) {
      var time = i * delta;

      retarget(target, source, options);

      for (var j = 0; j < bones.length; ++j) {
        name = options.names[bones[j].name] || bones[j].name;

        boneTo = getBoneByName(name, source.skeleton);

        if (boneTo) {
          bone = bones[j];
          boneData = boneDatas[j] = boneDatas[j] ?? {"bone": bone};

          if (options.hip == name) {
            if (!boneData.pos) {
              boneData.pos = {"times": new Float32Array(numFrames), "values": new Float32Array(numFrames * 3)};
            }

            if (options.useFirstFramePosition) {
              if (i == 0) {
                positionOffset = bone.position.clone();
              }

              bone.position.sub(positionOffset);
            }

            boneData.pos.times[i] = time;

            bone.position.toArray(boneData.pos.values, i * 3);
          }

          if (!boneData.quat) {
            boneData.quat = {"times": new Float32Array(numFrames), "values": new Float32Array(numFrames * 4)};
          }

          boneData.quat.times[i] = time;

          bone.quaternion.toArray(boneData.quat.values, i * 4);
        }
      }

      mixer.update(delta);

      source.updateMatrixWorld();
    }

    for (var i = 0; i < boneDatas.length; ++i) {
      boneData = boneDatas[i];

      if (boneData) {
        if (boneData.pos) {
          convertedTracks.add(new VectorKeyframeTrack(
              '.bones[' + boneData.bone.name + '].position', boneData.pos.times, boneData.pos.values, null));
        }

        convertedTracks.add(new QuaternionKeyframeTrack(
            '.bones[' + boneData.bone.name + '].quaternion', boneData.quat.times, boneData.quat.values, null));
      }
    }

    mixer.uncacheAction(clip);

    return new AnimationClip(clip.name, -1, convertedTracks);
  }

  static getHelperFromSkeleton(skeleton) {
    var source = new SkeletonHelper(skeleton.bones[0]);
    source.skeleton = skeleton;

    return source;
  }

  static getSkeletonOffsets(target, source, [options]) {
    options = options ?? {};

    var targetParentPos = new Vector3(),
        targetPos = new Vector3(),
        sourceParentPos = new Vector3(),
        sourcePos = new Vector3(),
        targetDir = new Vector2(),
        sourceDir = new Vector2();

    options.hip = options.hip != null ? options.hip : 'hip';
    options.names = options.names ?? {};

    if (!source.isObject3D) {
      source = getHelperFromSkeleton(source);
    }

    var nameKeys = options.names.keys,
        nameValues = options.names.values,
        sourceBones = source.isObject3D ? source.skeleton.bones : getBones(source),
        bones = target.isObject3D ? target.skeleton.bones : getBones(target),
        offsets = [];

    var bone, boneTo, name, i;

    target.skeleton.pose();

    for (i = 0; i < bones.length; ++i) {
      bone = bones[i];
      name = options.names[bone.name] || bone.name;

      boneTo = getBoneByName(name, sourceBones);

      if (boneTo && name != options.hip) {
        var boneParent = getNearestBone(bone.parent, nameKeys),
            boneToParent = getNearestBone(boneTo.parent, nameValues);

        boneParent.updateMatrixWorld();
        boneToParent.updateMatrixWorld();

        targetParentPos.setFromMatrixPosition(boneParent.matrixWorld);
        targetPos.setFromMatrixPosition(bone.matrixWorld);

        sourceParentPos.setFromMatrixPosition(boneToParent.matrixWorld);
        sourcePos.setFromMatrixPosition(boneTo.matrixWorld);

        targetDir
            .subVectors(new Vector2(targetPos.x, targetPos.y), new Vector2(targetParentPos.x, targetParentPos.y))
            .normalize();

        sourceDir
            .subVectors(new Vector2(sourcePos.x, sourcePos.y), new Vector2(sourceParentPos.x, sourceParentPos.y))
            .normalize();

        var laterialAngle = targetDir.angle() - sourceDir.angle();

        var offset = new Matrix4().makeRotationFromEuler(new Euler(0, 0, laterialAngle));

        bone.matrix.multiply(offset);

        bone.matrix.decompose(bone.position, bone.quaternion, bone.scale);

        bone.updateMatrixWorld();

        offsets[name] = offset;
      }
    }

    return offsets;
  }

  static renameBones(skeleton, names) {
    var bones = getBones(skeleton);

    for (var i = 0; i < bones.length; ++i) {
      var bone = bones[i];

      if (names[bone.name]) {
        bone.name = names[bone.name];
      }
    }

    // TODO how return this;
    print("SkeletonUtils.renameBones need confirm how return this  ");

    // return this;
  }

  static getBones(skeleton) {
    return skeleton is List ? skeleton : skeleton.bones;
  }

  static getBoneByName(name, skeleton) {
    for (var i = 0, bones = getBones(skeleton); i < bones.length; i++) {
      if (name == bones[i].name) return bones[i];
    }
  }

  static getNearestBone(bone, names) {
    while (bone.isBone) {
      if (names.indexOf(bone.name) != -1) {
        return bone;
      }

      bone = bone.parent;
    }
  }

  static findBoneTrackData(name, tracks) {
    var regexp = RegExp(r"\[(.*)\]\.(.*)");

    var result = {"name": name};

    for (var i = 0; i < tracks.length; ++i) {
      // 1 is track name
      // 2 is track type
      var trackData = regexp.firstMatch(tracks[i].name);

      if (trackData != null && name == trackData.group(1)) {
        result[trackData.group(2)!] = i;
      }
    }

    return result;
  }

  static getEqualsBonesNames(skeleton, targetSkeleton) {
    var sourceBones = getBones(skeleton), targetBones = getBones(targetSkeleton), bones = [];

    search:
    for (var i = 0; i < sourceBones.length; i++) {
      var boneName = sourceBones[i].name;

      for (var j = 0; j < targetBones.length; j++) {
        if (boneName == targetBones[j].name) {
          bones.add(boneName);

          continue search;
        }
      }
    }

    return bones;
  }

  static clone(source) {
    var sourceLookup = new Map();
    var cloneLookup = new Map();

    var clone = source.clone();

    parallelTraverse(source, clone, (sourceNode, clonedNode) {
      // sourceLookup.set( clonedNode, sourceNode );
      // cloneLookup.set( sourceNode, clonedNode );

      sourceLookup[clonedNode] = sourceNode;
      cloneLookup[sourceNode] = clonedNode;
    });

    clone.traverse((node) {
      if (node==null|| !(node is  SkinnedMesh)) //|| !node.runtimeType.toString().contains("SkinnedMesh"))
        return;//!node.runtimeType.toString().contains("SkinnedMesh")) return; // GL

      var clonedMesh = node;
      var sourceMesh = sourceLookup[node];
      var sourceBones = sourceMesh.skeleton.bones;

      clonedMesh.skeleton = sourceMesh.skeleton.clone();
      if (sourceMesh!=null&&clonedMesh!=null&&sourceMesh.bindMatrix!=null&&clonedMesh.bindMatrix!=null) { //GL
        clonedMesh.bindMatrix!.copy(sourceMesh!.bindMatrix);

        clonedMesh.skeleton!.bones = List<Bone>.from(sourceBones.map((bone) {
          return cloneLookup[bone];
        }).toList());

        clonedMesh.bind(clonedMesh.skeleton!, clonedMesh.bindMatrix!);
      }
    });

    return clone;
  }

  static parallelTraverse(a, b, callback) {
    callback(a, b);

    for (var i = 0; i < a.children.length; i++) {
      var _bc = null;

      if (b != null && i < b.children.length) {
        _bc = b.children[i];
      }

      parallelTraverse(a.children[i], _bc, callback);
    }
  }
}
