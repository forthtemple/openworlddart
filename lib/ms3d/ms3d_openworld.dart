// MilkShape 3D (.ms3d) and Valve SMD (.smd) support for openworld.
//
// Models load as an ordinary THREE.Group of meshes and actors load as a
// skinned hierarchy with THREE.AnimationClips, so everything else in
// openworld (Space.objTurn, Mob.moveTo, Actor.playAction, Config,
// SkeletonUtils cloning, ...) works with them just like with .glb files.
//
// Structure produced (same shape as a glTF scene, so openworld's
// `children[0].position.y += z` and Config cloning behave the same):
//
//   root (Group)                      <- what you position / turn
//     └ holder (Group, rotated 180°)  <- openworld turns objects by -t-180
//         ├ ms3d_root (Bone)          <- actors only
//         │   └ ms3d_j0, ms3d_j1 ...  <- one Bone per MS3D joint
//         └ one Mesh / SkinnedMesh per MS3D group, named after the group
//
// MS3D animation is kept faithful to the MudClient3D engine: an animation
// .ms3d supplies the skeleton (bind pose + keys), mesh vertices are bound
// to one bone each (their boneId), and key times are frames played at
// `interval` milliseconds per frame. The conversion to bone tracks is
// exact: per joint, local = bind * key, i.e.
//   position track   = bindPos + bindRot * keyPos
//   quaternion track = bindQuat * keyQuat
// (checked against the engine's own CPU skinning to ~1e-6).

import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:three_js/three_js.dart' as THREE;

import '../asset_pack.dart';
import 'ms3d.dart';
import 'smd.dart';

/// One animation of an actor (config.xml ACTORANIMATION).
class Ms3dAnimDef {
  final String filename; // animation .ms3d or .smd (asset path)
  final int interval; // milliseconds per frame
  final bool playOnce;
  const Ms3dAnimDef(this.filename, {this.interval = 100, this.playOnce = false});

  factory Ms3dAnimDef.fromJson(Map json) => Ms3dAnimDef(
        json['filename'],
        interval: (json['interval'] ?? 100).toInt(),
        playOnce: json['mode'] == 'playonce' || json['mode'] == 'playoncebackward',
      );
}

class Ms3dLoader {
  /// Prefix added to MS3D material/texture names that aren't full asset
  /// paths (MS3D material names in these games are paths relative to the
  /// old asset folder, e.g. "models/sand.png").
  static String textureRoot = 'assets/';

  /// GL_ALPHA_TEST threshold used for .png textures (TEXTURELIST depthtest).
  static double alphaTest = 0.2;

  /// Plain colours used as material/texture names in MudClient3D models
  /// (e.g. "black", "brownshiny"); used when no texture file matches.
  static final Map<String, int> namedColors = {
    'black': 0x000000,
    'blackshiny': 0x111111,
    'brown': 0x211e14,
    'brownshiny': 0x2a2519,
    'grey': 0x444444,
    'white': 0xffffff,
    'red': 0xff0000,
    'green': 0x00ff00,
    'blue': 0x0000ff,
    'yellow': 0xffff33,
    'purple': 0x880088,
  };

  /// Named animation sets: set name -> animation name -> definition.
  /// Filled from config.json "actoranimations" by [loadAnimationSets] or set
  /// directly in code.
  static final Map<String, Map<String, Ms3dAnimDef>> animationSets = {};

  static final Map<String, Future<Ms3dModel>> _models = {};
  static final Map<String, Future<THREE.Texture?>> _textures = {};
  static final Map<String, THREE.AnimationClip> _clips = {};

  static bool isMs3dPath(String? path) {
    if (path == null) return false;
    final p = path.toLowerCase();
    return p.endsWith('.ms3d') || p.endsWith('.smd');
  }

  /// Reads `"actoranimations": {"man": {"idle": {"filename":..., "interval":100}, ...}}`.
  static void loadAnimationSets(Map? json) {
    if (json == null) return;
    json.forEach((set, anims) {
      final m = <String, Ms3dAnimDef>{};
      (anims as Map).forEach((name, def) => m[name] = Ms3dAnimDef.fromJson(def));
      animationSets[set] = m;
    });
  }

  /// Parsed MS3D (or SMD converted to the same structure), cached.
  static Future<Ms3dModel> loadMs3d(String path) {
    return _models.putIfAbsent(path, () async {
      if (path.toLowerCase().endsWith('.smd')) {
        return SmdFile.parse(await AssetPack.loadString(path)).toMesh();
      }
      return Ms3dModel.parse(await AssetPack.loadBytes(path));
    });
  }

  static String _dir(String path) => path.contains('/') ? path.substring(0, path.lastIndexOf('/') + 1) : '';

  /// Resolves the texture for an MS3D material the way MudClient3D did:
  /// texturereplace[material name], else the material name itself; if that
  /// isn't a file, the material's texture file next to the model.
  static List<String> _textureCandidates(String modelPath, Ms3dMaterial mat, Map<String, String>? replace) {
    final out = <String>[];
    String full(String p) => p.startsWith(textureRoot) || p.startsWith('assets/') ? p : '$textureRoot$p';
    final r = replace?[mat.name];
    if (r != null && namedColors.containsKey(r)) return out; // plain colour, no texture
    if (r != null) out.add(full(r));
    if (mat.name.contains('.')) out.add(full(mat.name));
    if (mat.texture.isNotEmpty) {
      final base = mat.texture.split('/').last;
      out.add('${_dir(modelPath)}$base');
    }
    return out;
  }

  static Future<(THREE.Texture?, String?)> _loadTexture(List<String> candidates) async {
    for (final c in candidates) {
      final t = await _textures.putIfAbsent(c, () async {
        try {
          if (!AssetPack.contains(c)) {
            await AssetPack.loadBytes(c); // throws if missing from the bundle
          }
          final tex = await AssetPack.loadTexture(c);
          if (tex == null) return null;
          // MS3D t=0 is the top row; openworld loads textures unflipped.
          tex.flipY = false;
          tex.colorSpace = 'srgb';
          tex.wrapS = THREE.RepeatWrapping;
          tex.wrapT = THREE.RepeatWrapping;
          if (kIsWeb) {
            // Same fix as Model.setTexture: textures come in flipped on web.
            tex.repeat.y = -1.0;
          }
          tex.needsUpdate = true;
          return tex;
        } catch (_) {
          return null;
        }
      });
      if (t != null) return (t, c);
    }
    debugPrint('ms3d: texture not found ${candidates.join(' | ')}');
    return (null, null);
  }

  /// A texture loaded the way model textures are (MS3D orientation), for
  /// swapping a model material's map at runtime (e.g. a sky dome texture).
  static Future<THREE.Texture?> loadTexture(String path) async => (await _loadTexture([path])).$1;

  static Future<List<THREE.Material>> _materials(String path, Ms3dModel m,
      {Map<String, String>? texturereplace, bool basic = false}) async {
    final mats = <THREE.Material>[];
    for (final mat in m.materials) {
      final cands = _textureCandidates(path, mat, texturereplace);
      final (tex, used) = await _loadTexture(cands);
      final isPng = used != null && used.toLowerCase().endsWith('.png');
      final THREE.Material material;
      if (basic) {
        material = THREE.MeshBasicMaterial();
      } else {
        final std = THREE.MeshStandardMaterial();
        std.roughness = 1.0;
        std.metalness = 0.0;
        material = std;
      }
      material.map = tex;
      material.name = mat.name;
      // MudClient3D colour "textures" (TEXTURELIST texture="black" ambient=...)
      if (tex == null) {
        final col = namedColors[texturereplace?[mat.name] ?? mat.name];
        if (col != null) material.color = THREE.Color.fromHex32(col);
      }
      if (isPng) {
        material.transparent = true;
        material.alphaTest = alphaTest;
      }
      if (mat.transparency < 1.0 && mat.transparency > 0.0) {
        material.transparent = true;
        material.opacity = mat.transparency;
      }
      mats.add(material);
    }
    return mats;
  }

  /// Builds non-indexed geometry for the given triangles (MS3D stores
  /// normals and UVs per corner). Returns the geometry and the source
  /// vertex index of every corner (for skin attributes).
  static (THREE.BufferGeometry, Uint16List) _geometry(Ms3dModel m, List<int> tris) {
    final n = tris.length;
    final pos = Float32List(n * 9), nor = Float32List(n * 9), uv = Float32List(n * 6);
    final corner = Uint16List(n * 3);
    for (var i = 0; i < n; i++) {
      final t = tris[i];
      for (var k = 0; k < 3; k++) {
        final c = i * 3 + k;
        final v = m.triangleVertexIndices[t * 3 + k];
        corner[c] = v;
        pos[c * 3] = m.positions[v * 3];
        pos[c * 3 + 1] = m.positions[v * 3 + 1];
        pos[c * 3 + 2] = m.positions[v * 3 + 2];
        nor[c * 3] = m.triangleNormals[t * 9 + k * 3];
        nor[c * 3 + 1] = m.triangleNormals[t * 9 + k * 3 + 1];
        nor[c * 3 + 2] = m.triangleNormals[t * 9 + k * 3 + 2];
        uv[c * 2] = m.triangleS[t * 3 + k];
        uv[c * 2 + 1] = m.triangleT[t * 3 + k];
      }
    }
    final geo = THREE.BufferGeometry();
    geo.setAttributeFromString('position', _f32(pos, 3));
    geo.setAttributeFromString('normal', _f32(nor, 3));
    geo.setAttributeFromString('uv', _f32(uv, 2));
    geo.computeBoundingSphere();
    return (geo, corner);
  }

  // three_js 0.2.4's buffer attributes need its own native arrays
  // (THREE.Float32Array / THREE.Uint16Array, filled by index), not
  // dart:typed_data lists (those only work from three_js 0.3).
  static THREE.Float32BufferAttribute _f32(Float32List src, int itemSize) {
    final a = THREE.Float32Array(src.length);
    for (var i = 0; i < src.length; i++) {
      a[i] = src[i];
    }
    return THREE.Float32BufferAttribute(a, itemSize);
  }

  static THREE.Uint16BufferAttribute _u16(Uint16List src, int itemSize) {
    final a = THREE.Uint16Array(src.length);
    for (var i = 0; i < src.length; i++) {
      a[i] = src[i];
    }
    return THREE.Uint16BufferAttribute(a, itemSize);
  }

  /// Groups to build meshes for: one per MS3D group, or (with [merge]) one
  /// per distinct (group name, material) pair — big terrains often have
  /// hundreds of small groups sharing names and materials.
  static List<(String, int, List<int>)> _meshGroups(Ms3dModel m, bool merge) {
    final out = <(String, int, List<int>)>[];
    final index = <String, int>{};
    for (final g in m.groups) {
      final tris = [for (final t in g.triangleIndices) t];
      if (!merge) {
        out.add((g.name, g.materialIndex, tris));
        continue;
      }
      final key = '${g.name}\u0000${g.materialIndex}';
      final i = index[key];
      if (i == null) {
        index[key] = out.length;
        out.add((g.name, g.materialIndex, tris));
      } else {
        out[i].$3.addAll(tris);
      }
    }
    return out;
  }

  /// Loads a static model. Mesh names are the MS3D group names (so
  /// BaseObject.setVisible(obj, false, groupname: 'bubbles') works); each
  /// mesh also keeps the original name in extra['groupname'].
  ///
  /// [rename] can rename groups, e.g. to add openworld's "surface" tag to
  /// walkable terrain groups. [merge] combines groups that end up with the
  /// same name and material into one mesh (fewer draw calls for terrains).
  /// [turnfix] adds the 180° turn that openworld's objTurn expects (set it
  /// false for something placed directly in world coordinates, like a
  /// terrain).
  static Future<THREE.Group> createModel(
    String path, {
    Map<String, String>? texturereplace,
    bool basic = false,
    bool castshadow = false,
    bool merge = false,
    bool turnfix = true,
    String Function(String groupName, int groupIndex)? rename,
    Set<String> hidegroups = const {},
  }) async {
    final m = await loadMs3d(path);
    final mats = await _materials(path, m, texturereplace: texturereplace, basic: basic);
    final fallback = THREE.MeshStandardMaterial();
    final root = THREE.Group();
    final holder = THREE.Group();
    if (turnfix) holder.rotation.y = math.pi; // see header: cancels objTurn's extra 180°
    root.add(holder);

    final entries = <(String, String, int, List<int>)>[]; // name, original, material, tris
    final index = <String, int>{};
    for (var gi = 0; gi < m.groups.length; gi++) {
      final g = m.groups[gi];
      final name = rename != null ? rename(g.name, gi) : g.name;
      final tris = [for (final t in g.triangleIndices) t];
      final key = '$name\u0000${g.materialIndex}';
      final i = merge ? index[key] : null;
      if (i == null) {
        index[key] = entries.length;
        entries.add((name, g.name, g.materialIndex, tris));
      } else {
        entries[i].$4.addAll(tris);
      }
    }
    for (final (name, original, mi, tris) in entries) {
      final (geo, _) = _geometry(m, tris);
      final mesh = THREE.Mesh(geo, mi >= 0 ? mats[mi] : fallback);
      mesh.name = name;
      mesh.extra['groupname'] = original;
      mesh.castShadow = castshadow;
      mesh.visible = !hidegroups.contains(original);
      holder.add(mesh);
    }
    root.extra['path'] = path;
    root.extra['ms3d'] = m;
    root.castShadow = castshadow;
    return root;
  }

  /// Applies an item transform the way MudClient3D did for a MODEL/ACTOR
  /// inside an OBJECT (turn, pitch, scale and z offset, applied in the
  /// model's own frame). Use on objects from [createModel]/[createActor].
  static void setItemTransform(THREE.Object3D obj,
      {double turn = 0, double pitch = 0, double scale = 1, double z = 0, bool turnfix = true}) {
    final holder = obj.children[0];
    holder.rotation.order = THREE.RotationOrders.yxz;
    holder.rotation.y = (turnfix ? math.pi : 0) + turn * math.pi / 180;
    holder.rotation.x = pitch * math.pi / 180;
    holder.scale.setValues(scale, scale, scale);
    holder.position.y = z;
  }

  static THREE.Quaternion _quat(double x, double y, double z) {
    final q = Float64List(4);
    ms3dAngleQuaternion(x, y, z, q);
    return THREE.Quaternion(q[0], q[1], q[2], q[3]);
  }

  /// Converts an MS3D/SMD animation into a clip for bones named ms3d_j<i>.
  static Future<THREE.AnimationClip> loadClip(String name, Ms3dAnimDef def) async {
    final key = '$name|${def.filename}|${def.interval}';
    final cached = _clips[key];
    if (cached != null) return cached;
    final isSmd = def.filename.toLowerCase().endsWith('.smd');
    final List<Ms3dJoint> joints;
    final int totalFrames;
    if (isSmd) {
      final smd = SmdFile.parse(await AssetPack.loadString(def.filename));
      joints = smd.toJoints();
      totalFrames = smd.frameTimes.isEmpty ? 1 : smd.frameTimes.last + 1;
    } else {
      final a = await loadMs3d(def.filename);
      joints = a.joints;
      totalFrames = a.totalFrames;
    }
    final secPerFrame = def.interval / 1000.0;
    final tracks = <THREE.KeyframeTrack>[];
    for (var i = 0; i < joints.length; i++) {
      final j = joints[i];
      final qb = _quat(j.rotation[0], j.rotation[1], j.rotation[2]);
      final rk = j.rotationKeys;
      if (rk.length > 0) {
        final times = <double>[], vals = <double>[];
        for (var k = 0; k < rk.length; k++) {
          times.add(rk.times[k] * secPerFrame);
          final qk = _quat(rk.values[k * 3], rk.values[k * 3 + 1], rk.values[k * 3 + 2]);
          // SMD frames are absolute; MS3D keys are relative to the bind pose.
          final q = isSmd ? qk : qb.clone().multiply(qk);
          vals.addAll([q.x, q.y, q.z, q.w]);
        }
        tracks.add(THREE.QuaternionKeyframeTrack('ms3d_j$i.quaternion', times, vals));
      }
      final pk = j.positionKeys;
      if (pk.length > 0) {
        final times = <double>[], vals = <double>[];
        for (var k = 0; k < pk.length; k++) {
          times.add(pk.times[k] * secPerFrame);
          final v = THREE.Vector3(pk.values[k * 3], pk.values[k * 3 + 1], pk.values[k * 3 + 2]);
          if (isSmd) {
            vals.addAll([v.x, v.y, v.z]);
          } else {
            v.applyQuaternion(qb);
            vals.addAll([j.position[0] + v.x, j.position[1] + v.y, j.position[2] + v.z]);
          }
        }
        tracks.add(THREE.VectorKeyframeTrack('ms3d_j$i.position', times, vals));
      }
    }
    final clip = THREE.AnimationClip(name, math.max(1, totalFrames) * secPerFrame, tracks);
    _clips[key] = clip;
    return clip;
  }

  /// Creates an animated actor, ready for openworld's Actor/Mob functions.
  ///
  /// [animations] is the name of a set in [animationSets] (e.g. "man") or a
  /// map of animation name -> definition. The skeleton (bones and bind
  /// pose) is taken from the set's "idle" animation, or its first one, as
  /// in MudClient3D; if no animation is given the mesh's own joints are used.
  static Future<THREE.Object3D> createActor(
    String path, {
    dynamic animations,
    Map<String, String>? texturereplace,
    String? action = 'idle',
    bool basic = false,
    bool castshadow = false,
    double? randomduration,
    double? startat,
    double? duration,
    double? z,
    Set<String> hidegroups = const {},
  }) async {
    final m = await loadMs3d(path);
    final Map<String, Ms3dAnimDef> anims = animations is String
        ? (animationSets[animations] ?? const {})
        : (animations is Map<String, Ms3dAnimDef> ? animations : const {});

    // Skeleton source.
    List<Ms3dJoint> joints = m.joints;
    if (anims.isNotEmpty) {
      final skelDef = anims['idle'] ?? anims.values.first;
      if (skelDef.filename.toLowerCase().endsWith('.smd')) {
        joints = SmdFile.parse(await AssetPack.loadString(skelDef.filename)).toJoints();
      } else {
        joints = (await loadMs3d(skelDef.filename)).joints;
      }
    }

    final mats = await _materials(path, m, texturereplace: texturereplace, basic: basic);
    final fallback = THREE.MeshStandardMaterial();

    final root = THREE.Group();
    final holder = THREE.Group();
    holder.rotation.y = math.pi;
    root.add(holder);

    // Bones: an identity root bone (for vertices without a joint) + joints.
    final rootBone = THREE.Bone();
    rootBone.name = 'ms3d_root';
    holder.add(rootBone);
    final bones = <THREE.Bone>[];
    for (var i = 0; i < joints.length; i++) {
      final j = joints[i];
      final b = THREE.Bone();
      b.name = 'ms3d_j$i';
      b.position.setValues(j.position[0], j.position[1], j.position[2]);
      final q = _quat(j.rotation[0], j.rotation[1], j.rotation[2]);
      b.quaternion.set(q.x, q.y, q.z, q.w);
      bones.add(b);
    }
    for (var i = 0; i < joints.length; i++) {
      final p = joints[i].parentIndex;
      (p >= 0 && p < bones.length ? bones[p] : rootBone).add(bones[i]);
    }
    // Bind pose inverses, computed relative to the holder.
    root.updateMatrixWorld(true);
    final holderInv = holder.matrixWorld.clone().invert();
    final allBones = <THREE.Bone>[rootBone, ...bones];
    final inverses = [
      for (final b in allBones) holderInv.clone().multiply(b.matrixWorld).invert()
    ];
    final skeleton = THREE.Skeleton(allBones, inverses);

    for (final (name, mi, tris) in _meshGroups(m, false)) {
      final (geo, corner) = _geometry(m, tris);
      final n = corner.length;
      final si = Uint16List(n * 4), sw = Float32List(n * 4);
      for (var c = 0; c < n; c++) {
        final b = m.boneIds[corner[c]];
        si[c * 4] = (b >= 0 && b < bones.length) ? b + 1 : 0; // +1: slot 0 is ms3d_root
        sw[c * 4] = 1.0;
      }
      geo.setAttributeFromString('skinIndex', _u16(si, 4));
      geo.setAttributeFromString('skinWeight', _f32(sw, 4));
      final mesh = THREE.SkinnedMesh(geo, mi >= 0 ? mats[mi] : fallback);
      mesh.name = name;
      mesh.extra['groupname'] = name;
      mesh.castShadow = castshadow;
      mesh.frustumCulled = false; // bounds move with the animation
      mesh.visible = !hidegroups.contains(name);
      holder.add(mesh);
      mesh.bind(skeleton, THREE.Matrix4.identity());
    }

    // Clips.
    final clips = <THREE.AnimationClip>[];
    for (final e in anims.entries) {
      try {
        clips.add(await loadClip(e.key, e.value));
      } catch (err) {
        debugPrint('ms3d: animation ${e.value.filename} failed: $err');
      }
    }
    root.extra['animations'] = clips;
    root.extra['path'] = path;
    root.extra['ms3d'] = m;
    root.extra['ms3danimations'] = anims;
    root.extra['origrotation'] = root.rotation;
    root.castShadow = castshadow;
    if (z != null) holder.position.y += z;
    return root;
  }

  /// MudClient3D OBJECT wieldbone: a MODEL wielded by an actor (a zombie's
  /// head or arm, the mower). MudClient drew it inside the actor with its
  /// vertices skinned to one joint, so the model's own scale/z are ignored
  /// here (they only apply when the item is dropped on the ground). Each
  /// group becomes a SkinnedMesh on [actor]'s skeleton with every vertex
  /// bound to joint [joint]; the meshes are added to the actor's holder and
  /// returned (remove them, or hide them, to unwield).
  static Future<List<THREE.SkinnedMesh>> addWieldMeshes(
    THREE.Object3D actor,
    String path,
    int joint, {
    Map<String, String>? texturereplace,
    Set<String> hidegroups = const {},
  }) async {
    final m = await loadMs3d(path);
    final holder = actor.children[0];
    THREE.Skeleton? skeleton;
    for (final c in holder.children) {
      if (c is THREE.SkinnedMesh && c.skeleton != null) {
        skeleton = c.skeleton;
        break;
      }
    }
    final skel = skeleton;
    if (skel == null) return const [];
    final mats = await _materials(path, m, texturereplace: texturereplace);
    final fallback = THREE.MeshStandardMaterial();
    // Slot 0 is ms3d_root, joint i is slot i + 1.
    final slot = (joint >= 0 && joint + 1 < skel.bones.length) ? joint + 1 : 0;
    final out = <THREE.SkinnedMesh>[];
    for (final (name, mi, tris) in _meshGroups(m, false)) {
      final (geo, corner) = _geometry(m, tris);
      final n = corner.length;
      final si = Uint16List(n * 4), sw = Float32List(n * 4);
      for (var c = 0; c < n; c++) {
        si[c * 4] = slot;
        sw[c * 4] = 1.0;
      }
      geo.setAttributeFromString('skinIndex', _u16(si, 4));
      geo.setAttributeFromString('skinWeight', _f32(sw, 4));
      final mesh = THREE.SkinnedMesh(geo, mi >= 0 ? mats[mi] : fallback);
      mesh.name = name;
      mesh.extra['groupname'] = name;
      mesh.extra['wield'] = path;
      mesh.frustumCulled = false;
      mesh.visible = !hidegroups.contains(name);
      holder.add(mesh);
      mesh.bind(skel, THREE.Matrix4.identity());
      out.add(mesh);
    }
    return out;
  }

  /// Clip duration in seconds for [name] on an actor created by
  /// [createActor] (frames * interval), or null.
  static double? clipDuration(THREE.Object3D actor, String name) {
    for (final THREE.AnimationClip c in (actor.extra['animations'] ?? const [])) {
      if (c.name == name) return c.duration.toDouble();
    }
    return null;
  }
}
