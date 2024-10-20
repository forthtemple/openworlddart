part of jsm_loader;

/**
 * Loader loads FBX file and generates Group representing FBX scene.
 * Requires FBX file to be >= 7.0 and in ASCII or >= 6400 in Binary format
 * Versions lower than this may load but will probably have errors
 *
 * Needs Support:
 *  Morph normals / blend shape normals
 *
 * FBX format references:
 * 	https://help.autodesk.com/view/FBX/2017/ENU/?guid=__cpp_ref_index_html (C++ SDK reference)
 *
 * Binary format specification:
 *	https://code.blender.org/2013/08/fbx-binary-file-format-specification/
 */

late FBXTree fbxTree;
late Map connections;
var sceneGraph;

class FBXLoader extends Loader {
  late int innerWidth;
  late int innerHeight;

  FBXLoader(manager, innerWidth, innerHeight) : super(manager) {
    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;
  }

  loadAsync(url) async {
    var completer = Completer();

    load(url, (result) {
      completer.complete(result);
    });

    return completer.future;
  }

  load(url, Function onLoad, [Function? onProgress, Function? onError]) {
    var scope = this;

    var path =
        (scope.path == '') ? LoaderUtils.extractUrlBase(url) : scope.path;

    var loader = new FileLoader(this.manager);
    loader.setPath(scope.path);
    loader.setResponseType('arraybuffer');
    loader.setRequestHeader(scope.requestHeader);
    loader.setWithCredentials(scope.withCredentials);

    loader.load(url, (buffer) {
      // try {

      onLoad(scope.parse(buffer, path));

      // } catch ( e ) {

      // 	if ( onError != null ) {

      // 		onError( e );

      // 	} else {

      // 		print( e );

      // 	}

      // 	scope.manager.itemError( url );

      // }
    }, onProgress, onError);
  }

  parse(FBXBuffer, [String path = '', Function? onLoad, Function? onError]) {
    if (isFbxFormatBinary(FBXBuffer)) {
      fbxTree = new BinaryParser().parse(FBXBuffer);
    } else {
      var FBXText = convertArrayBufferToString(FBXBuffer);

      if (!isFbxFormatASCII(FBXText)) {
        throw ('THREE.FBXLoader: Unknown format.');
      }

      if (getFbxVersion(FBXText) < 7000) {
        throw ('THREE.FBXLoader: FBX version not supported, FileVersion: ' +
            getFbxVersion(FBXText));
      }

      fbxTree = TextParser().parse(FBXText);
    }

    // console.log( fbxTree );

    TextureLoader textureLoader = TextureLoader(this.manager)
        .setPath(
            (this.resourcePath == '' || this.resourcePath == null) ? path : '')
        .setCrossOrigin(this.crossOrigin);

    return FBXTreeParser(textureLoader, this.manager, this.innerWidth, this.innerHeight).parse();
  }

  @override
  FBXLoader setPath(String path) {
    super.setPath(path);
    return this;
  }
}

// Parse the FBXTree object returned by the BinaryParser or TextParser and return a Group
class FBXTreeParser {
  late Loader textureLoader;
  late dynamic manager;

  late int innerWidth;
  late int innerHeight;

  FBXTreeParser(Loader textureLoader, manager, int innerWidth, int innerHeight) {
    this.textureLoader = textureLoader;
    this.manager = manager;

    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;
  }

  parse() async {
    connections = this.parseConnections();
    var images = this.parseImages();

    var textures = await this.parseTextures(images);
    var materials = this.parseMaterials(textures);
    var deformers = this.parseDeformers();
    var geometryMap = GeometryParser().parse(deformers);

    this.parseScene(deformers, geometryMap, materials);

    return sceneGraph;
  }

  // Parses FBXTree.Connections which holds parent-child connections between objects (e.g. material -> texture, model->geometry )
  // and details the connection type
  parseConnections() {
    var connectionMap = new Map();

    if (fbxTree.Connections != null) {
      var rawConnections = fbxTree.Connections["connections"];

      rawConnections.forEach((rawConnection) {
        var fromID = rawConnection[0];
        var toID = rawConnection[1];

        dynamic relationship;
        if (rawConnection.length > 2) {
          relationship = rawConnection[2];
        }

        if (!connectionMap.containsKey(fromID)) {
          connectionMap[fromID] = {"parents": [], "children": []};
        }

        var parentRelationship = {"ID": toID, "relationship": relationship};
        connectionMap[fromID]["parents"].add(parentRelationship);

        if (!connectionMap.containsKey(toID)) {
          connectionMap[toID] = {"parents": [], "children": []};
        }

        var childRelationship = {"ID": fromID, "relationship": relationship};
        connectionMap[toID]["children"].add(childRelationship);
      });
    }

    return connectionMap;
  }

  // Parse FBXTree.Objects.Video for embedded image data
  // These images are connected to textures in FBXTree.Objects.Textures
  // via FBXTree.Connections.
  parseImages() {
    var images = {};
    var blobs = {};

    if (fbxTree.Objects["Video"] != null) {
      var videoNodes = fbxTree.Objects["Video"];

      for (var nodeID in videoNodes.keys) {
        var videoNode = videoNodes[nodeID];

        var id = parseInt(nodeID);

        images[id] = videoNode["RelativeFilename"] ?? videoNode["Filename"];

        // raw image data is in videoNode.Content
        if (videoNode["Content"] != null) {
          // var arrayBufferContent = ( videoNode["Content"] is ArrayBuffer ) && ( videoNode["Content"].byteLength > 0 );
          var arrayBufferContent = (videoNode["Content"] is TypedData) &&
              (videoNode["Content"].byteLength > 0);
          var base64Content =
              (videoNode["Content"] is String) && (videoNode["Content"] != '');

          if (arrayBufferContent || base64Content) {
            var image = this.parseImage(videoNodes[nodeID]);

            blobs[videoNode.RelativeFilename ?? videoNode.Filename] = image;
          }
        }
      }
    }

    for (var id in images.keys) {
      var filename = images[id];

      if (blobs[filename] != null)
        images[id] = blobs[filename];
      else
        images[id] = images[id].split('\\').removeLast();
    }

    return images;
  }

  // Parse embedded image data in FBXTree.Video.Content
  parseImage(videoNode) {
    var content = videoNode.Content;
    String fileName = videoNode.RelativeFilename ?? videoNode.Filename;
    var extension =
        fileName.substring(fileName.lastIndexOf('.') + 1).toLowerCase();

    var type;

    switch (extension) {
      case 'bmp':
        type = 'image/bmp';
        break;

      case 'jpg':
      case 'jpeg':
        type = 'image/jpeg';
        break;

      case 'png':
        type = 'image/png';
        break;

      case 'tif':
        type = 'image/tiff';
        break;

      case 'tga':
        if (this.manager.getHandler('.tga') == null) {
          print('FBXLoader: TGA loader not found, skipping ${fileName}');
        }

        type = 'image/tga';
        break;

      default:
        print('FBXLoader: Image type "${extension}" is not supported.');
        return;
    }

    if (content is String) {
      // ASCII format

      return 'data:' + type + ';base64,' + content;
    } else {
      // Binary Format

      var array = new Uint8Array(content);
      return createObjectURL(new Blob([array], {type: type}));
    }
  }

  // Parse nodes in FBXTree.Objects.Texture
  // These contain details such as UV scaling, cropping, rotation etc and are connected
  // to images in FBXTree.Objects.Video
  parseTextures(images) async {
    var textureMap = new Map();

    if (fbxTree.Objects["Texture"] != null) {
      var textureNodes = fbxTree.Objects["Texture"];
      for (var nodeID in textureNodes.keys) {
        var texture = await this.parseTexture(textureNodes[nodeID], images);
        textureMap[parseInt(nodeID)] = texture;
      }
    }

    return textureMap;
  }

  // Parse individual node in FBXTree.Objects.Texture
  parseTexture(textureNode, images) async {
    var texture = await this.loadTexture(textureNode, images);

    texture.id = textureNode["id"];

    texture.name = textureNode["attrName"];

    var wrapModeU = textureNode["WrapModeU"];
    var wrapModeV = textureNode["WrapModeV"];

    var valueU = wrapModeU != null ? wrapModeU.value : 0;
    var valueV = wrapModeV != null ? wrapModeV.value : 0;

    // http://download.autodesk.com/us/fbx/SDKdocs/FBX_SDK_Help/files/fbxsdkref/class_k_fbx_texture.html#889640e63e2e681259ea81061b85143a
    // 0: repeat(default), 1: clamp

    texture.wrapS = valueU == 0 ? RepeatWrapping : ClampToEdgeWrapping;
    texture.wrapT = valueV == 0 ? RepeatWrapping : ClampToEdgeWrapping;

    if (textureNode["Scaling"] != null) {
      var values = textureNode["Scaling"].value;

      texture.repeat.x = values[0];
      texture.repeat.y = values[1];
    }

    return texture;
  }

  // load a texture specified as a blob or data URI, or via an external URL using TextureLoader
  loadTexture(textureNode, images) async {
    var fileName;

    var currentPath = this.textureLoader.path;

    var children = connections[textureNode["id"]]["children"];

    if (children != null &&
        children.length > 0 &&
        images[children[0]["ID"]] != null) {
      fileName = images[children[0]["ID"]];
      if (fileName.indexOf('blob:') == 0 || fileName.indexOf('data:') == 0) {
        this.textureLoader.setPath('');
      }
    }

    var texture;

    String nodeFileName = textureNode["FileName"];

    var extension =
        nodeFileName.substring(nodeFileName.length - 3).toLowerCase();

    if (extension == 'tga') {
      var loader = this.manager.getHandler('.tga');

      if (loader == null) {
        print(
            'FBXLoader: TGA loader not found, creating placeholder texture for ${textureNode["RelativeFilename"]}');
        texture = new Texture();
      } else {
        loader.setPath(this.textureLoader.path);
        texture = loader.load(fileName);
      }
    } else if (extension == 'psd') {
      print(
          'FBXLoader: PSD textures are not supported, creating placeholder texture for ${textureNode["RelativeFilename"]}');
      texture = new Texture();
    } else {
      texture = await this.textureLoader.loadAsync(fileName);
    }

    this.textureLoader.setPath(currentPath);

    return texture;
  }

  // Parse nodes in FBXTree.Objects.Material
  parseMaterials(textureMap) {
    var materialMap = new Map();

    if (fbxTree.Objects["Material"] != null) {
      var materialNodes = fbxTree.Objects["Material"];

      for (var nodeID in materialNodes.keys) {
        var material = this.parseMaterial(materialNodes[nodeID], textureMap);

        if (material != null) materialMap[parseInt(nodeID)] = material;
      }
    }

    return materialMap;
  }

  // Parse single node in FBXTree.Objects.Material
  // Materials are connected to texture maps in FBXTree.Objects.Textures
  // FBX format currently only supports Lambert and Phong shading models
  parseMaterial(Map<String, dynamic> materialNode, Map textureMap) {
    var ID = materialNode["id"];
    var name = materialNode["attrName"];
    var type = materialNode["ShadingModel"];

    // Case where FBX wraps shading model in property object.
    if (type is! String) {
      type = type.value;
    }

    // Ignore unused materials which don't have any connections.
    if (!connections.containsKey(ID)) return null;

    Map parameters = this.parseParameters(materialNode, textureMap, ID);

    var material;

    switch (type.toLowerCase()) {
      case 'phong':
        material = new MeshPhongMaterial();
        break;
      case 'lambert':
        material = new MeshLambertMaterial();
        break;
      default:
        print(
            'THREE.FBXLoader: unknown material type "%s". Defaulting to MeshPhongMaterial.${type}');
        material = new MeshPhongMaterial();
        break;
    }

    material.setValues(parameters);
    material.name = name;

    return material;
  }

  // Parse FBX material and return parameters suitable for a three.js material
  // Also parse the texture map and return any textures associated with the material
  parseParameters(Map materialNode, textureMap, ID) {
    Map<String, dynamic> parameters = {};

    if (materialNode["BumpFactor"] != null) {
      parameters["bumpScale"] = materialNode["BumpFactor"]["value"];
    }

    if (materialNode["Diffuse"] != null) {
      parameters["color"] = new Color()
          .fromArray(List<double>.from(materialNode["Diffuse"]["value"]));
    } else if (materialNode["DiffuseColor"] != null &&
        (materialNode["DiffuseColor"]["type"] == 'Color' ||
            materialNode["DiffuseColor"]["type"] == 'ColorRGB')) {
      // The blender exporter exports diffuse here instead of in materialNode.Diffuse
      parameters["color"] = new Color()
          .fromArray(List<double>.from(materialNode["DiffuseColor"]["value"]));
    }

    if (materialNode["DisplacementFactor"] != null) {
      parameters["displacementScale"] =
          materialNode["DisplacementFactor"]["value"];
    }

    if (materialNode["Emissive"] != null) {
      parameters["emissive"] = new Color()
          .fromArray(List<double>.from(materialNode["Emissive"]["value"]));
    } else if (materialNode["EmissiveColor"] != null &&
        (materialNode["EmissiveColor"]["type"] == 'Color' ||
            materialNode["EmissiveColor"].type == 'ColorRGB')) {
      // The blender exporter exports emissive color here instead of in materialNode.Emissive
      parameters["emissive"] = new Color()
          .fromArray(List<double>.from(materialNode["EmissiveColor"]["value"]));
    }

    if (materialNode["EmissiveFactor"] != null) {
      parameters["emissiveIntensity"] =
          parseFloat(materialNode["EmissiveFactor"]["value"]);
    }

    if (materialNode["Opacity"] != null) {
      parameters["opacity"] =
          parseFloat(materialNode["Opacity"]["value"].toString());
    }

    if (parameters["opacity"] != null && parameters["opacity"] < 1.0) {
      parameters["transparent"] = true;
    }

    if (materialNode["ReflectionFactor"] != null) {
      parameters["reflectivity"] = materialNode["ReflectionFactor"]["value"];
    }

    if (materialNode["Shininess"] != null) {
      parameters["shininess"] = materialNode["Shininess"]["value"];
    }

    if (materialNode["Specular"] != null) {
      parameters["specular"] = new Color()
          .fromArray(List<double>.from(materialNode["Specular"]["value"]));
    } else if (materialNode["SpecularColor"] != null &&
        materialNode["SpecularColor"]["type"] == 'Color') {
      // The blender exporter exports specular color here instead of in materialNode.Specular
      parameters["specular"] = new Color()
          .fromArray(List<double>.from(materialNode["SpecularColor"]["value"]));
    }

    var scope = this;

    final connection = connections[ID];

    if (connection["children"] != null) {
      connection["children"].forEach((child) {
        var type = child["relationship"];

        var childID = child["ID"];

        switch (type) {
          case 'Bump':
            parameters["bumpMap"] = scope.getTexture(textureMap, childID);
            break;

          case 'Maya|TEX_ao_map':
            parameters["aoMap"] = scope.getTexture(textureMap, childID);
            break;

          case 'DiffuseColor':
          case 'Maya|TEX_color_map':
            parameters["map"] = scope.getTexture(textureMap, childID);
            if (parameters["map"] != null) {
              parameters["map"].encoding = sRGBEncoding;
            }

            break;

          case 'DisplacementColor':
            parameters["displacementMap"] =
                scope.getTexture(textureMap, childID);
            break;

          case 'EmissiveColor':
            parameters["emissiveMap"] = scope.getTexture(textureMap, childID);
            if (parameters["emissiveMap"] != null) {
              parameters["emissiveMap"].encoding = sRGBEncoding;
            }

            break;

          case 'NormalMap':
          case 'Maya|TEX_normal_map':
            parameters["normalMap"] = scope.getTexture(textureMap, childID);
            break;

          case 'ReflectionColor':
            parameters["envMap"] = scope.getTexture(textureMap, childID);
            if (parameters["envMap"] != null) {
              parameters["envMap"].mapping = EquirectangularReflectionMapping;
              parameters["envMap"].encoding = sRGBEncoding;
            }

            break;

          case 'SpecularColor':
            parameters["specularMap"] = scope.getTexture(textureMap, childID);
            if (parameters["specularMap"] != null) {
              parameters["specularMap"].encoding = sRGBEncoding;
            }

            break;

          case 'TransparentColor':
          case 'TransparencyFactor':
            parameters["alphaMap"] = scope.getTexture(textureMap, childID);
            parameters["transparent"] = true;
            break;

          case 'AmbientColor':
          case 'ShininessExponent': // AKA glossiness map
          case 'SpecularFactor': // AKA specularLevel
          case 'VectorDisplacementColor': // NOTE: Seems to be a copy of DisplacementColor
          default:
            print(
                'THREE.FBXLoader: %s map is not supported in three.js, skipping texture. ${type}');
            break;
        }
      });
    }

    return parameters;
  }

  // get a texture from the textureMap for use by a material.
  getTexture(textureMap, id) {
    // if the texture is a layered texture, just use the first layer and issue a warning
    if (fbxTree.Objects["LayeredTexture"] != null &&
        fbxTree.Objects["LayeredTexture"].id != null) {
      print(
          'THREE.FBXLoader: layered textures are not supported in three.js. Discarding all but first layer.');
      id = connections[id].children[0].ID;
    }

    return textureMap[id];
  }

  // Parse nodes in FBXTree.Objects.Deformer
  // Deformer node can contain skinning or Vertex Cache animation data, however only skinning is supported here
  // Generates map of Skeleton-like objects for use later when generating and binding skeletons.
  Map parseDeformers() {
    Map skeletons = {};
    Map morphTargets = {};

    if (fbxTree.Objects["Deformer"] != null) {
      var DeformerNodes = fbxTree.Objects["Deformer"];

      for (var nodeID in DeformerNodes.keys) {
        Map deformerNode = DeformerNodes[nodeID];

        var relationships = connections[parseInt(nodeID)];

        if (deformerNode["attrType"] == 'Skin') {
          var skeleton = this.parseSkeleton(relationships, DeformerNodes);
          skeleton["ID"] = nodeID;

          if (relationships["parents"].length > 1)
            print(
                'THREE.FBXLoader: skeleton attached to more than one geometry is not supported.');
          skeleton["geometryID"] = relationships["parents"][0]["ID"];

          skeletons[nodeID] = skeleton;
        } else if (deformerNode["attrType"] == 'BlendShape') {
          Map<String, dynamic> morphTarget = {
            "id": nodeID,
          };

          morphTarget["rawTargets"] =
              this.parseMorphTargets(relationships, DeformerNodes);
          morphTarget["id"] = nodeID;

          if (relationships["parents"].length > 1)
            print(
                'THREE.FBXLoader: morph target attached to more than one geometry is not supported.');

          morphTargets[nodeID] = morphTarget;
        }
      }
    }

    return {
      "skeletons": skeletons,
      "morphTargets": morphTargets,
    };
  }

  // Parse single nodes in FBXTree.Objects.Deformer
  // The top level skeleton node has type 'Skin' and sub nodes have type 'Cluster'
  // Each skin node represents a skeleton and each cluster node represents a bone
  Map<String, dynamic> parseSkeleton(relationships, deformerNodes) {
    var rawBones = [];

    relationships["children"].forEach((child) {
      var boneNode = deformerNodes[child["ID"]];

      if (boneNode["attrType"] != 'Cluster') return;

      var rawBone = {
        "ID": child["ID"],
        "indices": [],
        "weights": [],
        "transformLink":
            new Matrix4().fromArray(boneNode["TransformLink"]["a"]),
        // transform: new Matrix4().fromArray( boneNode.Transform.a ),
        // linkMode: boneNode.Mode,
      };

      if (boneNode["Indexes"] != null) {
        rawBone["indices"] = boneNode["Indexes"]["a"];
        rawBone["weights"] = boneNode["Weights"]["a"];
      }

      rawBones.add(rawBone);
    });

    return Map<String, dynamic>.from({"rawBones": rawBones, "bones": []});
  }

  // The top level morph deformer node has type "BlendShape" and sub nodes have type "BlendShapeChannel"
  parseMorphTargets(relationships, deformerNodes) {
    var rawMorphTargets = [];

    for (var i = 0; i < relationships.children.length; i++) {
      var child = relationships.children[i];

      var morphTargetNode = deformerNodes[child["ID"]];

      var rawMorphTarget = {
        "name": morphTargetNode.attrName,
        "initialWeight": morphTargetNode.DeformPercent,
        "id": morphTargetNode.id,
        "fullWeights": morphTargetNode.FullWeights.a
      };

      if (morphTargetNode.attrType != 'BlendShapeChannel') return;

      rawMorphTarget["geoID"] =
          connections[parseInt(child["ID"])].children.filter((child) {
        return child.relationship == null;
      })[0].ID;

      rawMorphTargets.add(rawMorphTarget);
    }

    return rawMorphTargets;
  }

  // create the main Group() to be returned by the loader
  parseScene(deformers, geometryMap, materialMap) {
    sceneGraph = new Group();

    Map modelMap =
        this.parseModels(deformers["skeletons"], geometryMap, materialMap);

    var modelNodes = fbxTree.Objects["Model"];

    var scope = this;
    modelMap.forEach((key, model) {
      var modelNode = modelNodes[model.id];
      scope.setLookAtProperties(model, modelNode);

      var parentConnections = connections[model.id]["parents"];

      parentConnections.forEach((connection) {
        var parent = modelMap[connection["ID"]];
        if (parent != null) parent.add(model);
      });

      if (model.parent == null) {
        sceneGraph.add(model);
      }
    });

    this.bindSkeleton(deformers["skeletons"], geometryMap, modelMap);

    this.createAmbientLight();

    sceneGraph.traverse((node) {
      if (node.userData["transformData"] != null) {
        if (node.parent != null) {
          node.userData["transformData"]["parentMatrix"] = node.parent.matrix;
          node.userData["transformData"]["parentMatrixWorld"] =
              node.parent.matrixWorld;
        }

        var transform = generateTransform(node.userData["transformData"]);

        node.applyMatrix4(transform);
        node.updateWorldMatrix(false, false);
      }
    });

    var animations = new AnimationParser().parse();

    // if all the models where already combined in a single group, just return that
    if (sceneGraph.children.length == 1 && sceneGraph.children[0] is Group) {
      sceneGraph.children[0].animations = animations;
      sceneGraph = sceneGraph.children[0];
    }

    sceneGraph.animations = animations;
  }

  // parse nodes in FBXTree.Objects.Model
  parseModels(skeletons, geometryMap, materialMap) {
    var modelMap = new Map();
    var modelNodes = fbxTree.Objects["Model"];

    for (var nodeID in modelNodes.keys) {
      var id = parseInt(nodeID);
      var node = modelNodes[nodeID];
      var relationships = connections[id];

      var model =
          this.buildSkeleton(relationships, skeletons, id, node["attrName"]);

      if (model == null) {
        switch (node["attrType"]) {
          case 'Camera':
            model = this.createCamera(relationships);
            break;
          case 'Light':
            model = this.createLight(relationships);
            break;
          case 'Mesh':
            model = this.createMesh(relationships, geometryMap, materialMap);
            break;
          case 'NurbsCurve':
            model = this.createCurve(relationships, geometryMap);
            break;
          case 'LimbNode':
          case 'Root':
            model = new Bone();
            break;
          case 'Null':
          default:
            model = new Group();
            break;
        }

        model.name = node["attrName"] != null
            ? PropertyBinding.sanitizeNodeName(node["attrName"])
            : '';

        model.id = id;
      }

      this.getTransformData(model, node);
      modelMap[id] = model;
    }

    return modelMap;
  }

  buildSkeleton(relationships, skeletons, id, name) {
    var bone = null;

    relationships["parents"].forEach((parent) {
      for (var ID in skeletons.keys) {
        var skeleton = skeletons[ID];

        skeleton["rawBones"].asMap().forEach((i, rawBone) {
          if (rawBone["ID"] == parent["ID"]) {
            var subBone = bone;
            bone = new Bone();

            bone.matrixWorld.copy(rawBone["transformLink"]);

            // set name and id here - otherwise in cases where "subBone" is created it will not have a name / id

            bone.name =
                name != null ? PropertyBinding.sanitizeNodeName(name) : '';
            bone.id = id;

            if (skeleton["bones"].length <= i) {
              final boneList =
                  List<Bone>.filled((i + 1) - skeleton["bones"].length, Bone());

              skeleton["bones"].addAll(boneList);
            }

            skeleton["bones"][i] = bone;

            // In cases where a bone is shared between multiple meshes
            // duplicate the bone here and and it as a child of the first bone
            if (subBone != null) {
              bone.add(subBone);
            }
          }
        });
      }
    });

    return bone;
  }

  // create a PerspectiveCamera or OrthographicCamera
  createCamera(relationships) {
    var model;
    var cameraAttribute;

    relationships.children.forEach((child) {
      var attr = fbxTree.Objects["NodeAttribute"][child["ID"]];

      if (attr != null) {
        cameraAttribute = attr;
      }
    });

    if (cameraAttribute == null) {
      model = new Object3D();
    } else {
      var type = 0;
      if (cameraAttribute.CameraProjectionType != null &&
          cameraAttribute.CameraProjectionType.value == 1) {
        type = 1;
      }

      var nearClippingPlane = 1;
      if (cameraAttribute.NearPlane != null) {
        nearClippingPlane = cameraAttribute.NearPlane.value / 1000;
      }

      var farClippingPlane = 1000;
      if (cameraAttribute.FarPlane != null) {
        farClippingPlane = cameraAttribute.FarPlane.value / 1000;
      }

      var width = innerWidth;
      var height = innerHeight;

      if (cameraAttribute.AspectWidth != null &&
          cameraAttribute.AspectHeight != null) {
        width = cameraAttribute.AspectWidth.value;
        height = cameraAttribute.AspectHeight.value;
      }

      var aspect = width / height;

      var fov = 45;
      if (cameraAttribute.FieldOfView != null) {
        fov = cameraAttribute.FieldOfView.value;
      }

      var focalLength = cameraAttribute.FocalLength
          ? cameraAttribute.FocalLength.value
          : null;

      switch (type) {
        case 0: // Perspective
          model = new PerspectiveCamera(
              fov, aspect, nearClippingPlane, farClippingPlane);
          if (focalLength != null) model.setFocalLength(focalLength);
          break;

        case 1: // Orthographic
          model = new OrthographicCamera(-width / 2, width / 2, height / 2,
              -height / 2, nearClippingPlane, farClippingPlane);
          break;

        default:
          print('THREE.FBXLoader: Unknown camera type ${type}.');
          model = new Object3D();
          break;
      }
    }

    return model;
  }

  // Create a DirectionalLight, PointLight or SpotLight
  createLight(relationships) {
    var model;
    var lightAttribute;

    relationships.children.forEach((child) {
      var attr = fbxTree.Objects["NodeAttribute"][child["ID"]];

      if (attr != null) {
        lightAttribute = attr;
      }
    });

    if (lightAttribute == null) {
      model = new Object3D();
    } else {
      var type;

      // LightType can be null for Point lights
      if (lightAttribute.LightType == null) {
        type = 0;
      } else {
        type = lightAttribute.LightType.value;
      }

      var color = Color.fromHex(0xffffff);

      if (lightAttribute.Color != null) {
        color = new Color().fromArray(lightAttribute.Color.value);
      }

      var intensity = (lightAttribute.Intensity == null)
          ? 1
          : lightAttribute.Intensity.value / 100;

      // light disabled
      if (lightAttribute.CastLightOnObject != null &&
          lightAttribute.CastLightOnObject.value == 0) {
        intensity = 0;
      }

      double distance = 0.0;
      if (lightAttribute.FarAttenuationEnd != null) {
        if (lightAttribute.EnableFarAttenuation != null &&
            lightAttribute.EnableFarAttenuation.value == 0) {
          distance = 0.0;
        } else {
          distance = lightAttribute.FarAttenuationEnd.value;
        }
      }

      // TODO: could this be calculated linearly from FarAttenuationStart to FarAttenuationEnd?
      double decay = 1.0;

      switch (type) {
        case 0: // Point
          model = new PointLight(color, intensity, distance, decay);
          break;

        case 1: // Directional
          model = new DirectionalLight(color, intensity);
          break;

        case 2: // Spot
          num angle = Math.PI / 3;

          if (lightAttribute.InnerAngle != null) {
            angle = MathUtils.degToRad(lightAttribute.InnerAngle.value);
          }

          num penumbra = 0;
          if (lightAttribute.OuterAngle != null) {
            // TODO: this is not correct - FBX calculates outer and inner angle in degrees
            // with OuterAngle > InnerAngle && OuterAngle <= Math.PI
            // while three.js uses a penumbra between (0, 1) to attenuate the inner angle
            penumbra = MathUtils.degToRad(lightAttribute.OuterAngle.value);
            penumbra = Math.max(penumbra, 1);
          }

          model =
              new SpotLight(color, intensity, distance, angle, penumbra, decay);
          break;

        default:
          print(
              'THREE.FBXLoader: Unknown light type ${lightAttribute.LightType.value}, defaulting to a PointLight.');
          model = new PointLight(color, intensity);
          break;
      }

      if (lightAttribute.CastShadows != null &&
          lightAttribute.CastShadows.value == 1) {
        model.castShadow = true;
      }
    }

    return model;
  }

  createMesh(relationships, Map geometryMap, materialMap) {
    var model;
    var geometry = null;
    var material = null;
    var materials = [];

    // get geometry and materials(s) from connections
    relationships["children"].forEach((child) {
      if (geometryMap.containsKey(child["ID"])) {
        geometry = geometryMap[child["ID"]];
      }

      if (materialMap.containsKey(child["ID"])) {
        materials.add(materialMap[child["ID"]]);
      }
    });

    if (materials.length > 1) {
      material = materials;
    } else if (materials.length > 0) {
      material = materials[0];
    } else {
      material = new MeshPhongMaterial({"color": 0xcccccc});
      materials.add(material);
    }

    if (geometry.attributes["color"] != null) {
      materials.forEach((material) {
        material.vertexColors = true;
      });
    }

    if (geometry.userData["FBX_Deformer"] != null) {
      model = new SkinnedMesh(geometry, material);
      model.normalizeSkinWeights();
    } else {
      model = new Mesh(geometry, material);
    }

    return model;
  }

  createCurve(relationships, geometryMap) {
    var geometry = relationships.children.reduce((geo, child) {
      if (geometryMap.has(child["ID"])) geo = geometryMap.get(child["ID"]);

      return geo;
    }, null);

    // FBX does not list materials for Nurbs lines, so we'll just put our own in here.
    var material = new LineBasicMaterial({"color": 0x3300ff, "linewidth": 1});
    return new Line(geometry, material);
  }

  // parse the model node for transform data
  getTransformData(model, Map modelNode) {
    var transformData = {};

    if (modelNode["InheritType"] != null)
      transformData["inheritType"] =
          parseInt(modelNode["InheritType"]["value"]);

    if (modelNode["RotationOrder"] != null)
      transformData["eulerOrder"] =
          getEulerOrder(modelNode["RotationOrder"]["value"]);
    else
      transformData["eulerOrder"] = 'ZYX';

    if (modelNode["Lcl_Translation"] != null)
      transformData["translation"] = modelNode["Lcl_Translation"]["value"];

    if (modelNode["PreRotation"] != null)
      transformData["preRotation"] = modelNode["PreRotation"]["value"];
    if (modelNode["Lcl_Rotation"] != null)
      transformData["rotation"] = modelNode["Lcl_Rotation"]["value"];
    if (modelNode["PostRotation"] != null)
      transformData["postRotation"] = modelNode["PostRotation"]["value"];

    if (modelNode["Lcl_Scaling"] != null)
      transformData["scale"] = modelNode["Lcl_Scaling"]["value"];

    if (modelNode["ScalingOffset"] != null)
      transformData["scalingOffset"] = modelNode["ScalingOffset"]["value"];
    if (modelNode["ScalingPivot"] != null)
      transformData["scalingPivot"] = modelNode["ScalingPivot"]["value"];

    if (modelNode["RotationOffset"] != null)
      transformData["rotationOffset"] = modelNode["RotationOffset"]["value"];
    if (modelNode["RotationPivot"] != null)
      transformData["rotationPivot"] = modelNode["RotationPivot"]["value"];

    model.userData["transformData"] = transformData;
  }

  setLookAtProperties(model, Map modelNode) {
    if (modelNode["LookAtProperty"] != null) {
      var children = connections[model.id].children;

      children.forEach((child) {
        if (child.relationship == 'LookAtProperty') {
          var lookAtTarget = fbxTree.Objects["Model"][child["ID"]];

          if (lookAtTarget.Lcl_Translation != null) {
            var pos = lookAtTarget.Lcl_Translation.value;

            // DirectionalLight, SpotLight
            if (model.target != null) {
              model.target.position.fromArray(pos);
              sceneGraph.add(model.target);
            } else {
              // Cameras and other Object3Ds

              model.lookAt(new Vector3().fromArray(pos));
            }
          }
        }
      });
    }
  }

  bindSkeleton(skeletons, geometryMap, modelMap) {
    var bindMatrices = this.parsePoseNodes();

    for (var ID in skeletons.keys) {
      var skeleton = skeletons[ID];

      var parents = connections[parseInt(skeleton["ID"])]["parents"];

      parents.forEach((parent) {
        if (geometryMap.containsKey(parent["ID"])) {
          var geoID = parent["ID"];
          var geoRelationships = connections[geoID];

          geoRelationships["parents"].forEach((geoConnParent) {
            if (modelMap.containsKey(geoConnParent["ID"])) {
              var model = modelMap[geoConnParent["ID"]];

              model.bind(new Skeleton(List<Bone>.from(skeleton["bones"])),
                  bindMatrices[geoConnParent["ID"]]);
            }
          });
        }
      });
    }
  }

  parsePoseNodes() {
    var bindMatrices = {};

    if (fbxTree.Objects.keys.contains("Pose")) {
      var BindPoseNode = fbxTree.Objects["Pose"];

      for (var nodeID in BindPoseNode.keys) {
        if (BindPoseNode[nodeID]["attrType"] == 'BindPose' &&
            BindPoseNode[nodeID]["NbPoseNodes"] > 0) {
          var poseNodes = BindPoseNode[nodeID]["PoseNode"];

          if (poseNodes is List) {
            poseNodes.forEach((poseNode) {
              bindMatrices[poseNode["Node"]] =
                  new Matrix4().fromArray(poseNode["Matrix"]["a"]);
            });
          } else {
            bindMatrices[poseNodes["Node"]] =
                new Matrix4().fromArray(poseNodes["Matrix"]["a"]);
          }
        }
      }
    }

    return bindMatrices;
  }

  // Parse ambient color in FBXTree.GlobalSettings - if it's not set to black (default), create an ambient light
  createAmbientLight() {
    if (fbxTree.GlobalSettings != null &&
        fbxTree.GlobalSettings!["AmbientColor"] != null) {
      var ambientColor = fbxTree.GlobalSettings!["AmbientColor"]["value"];
      var r = ambientColor[0];
      var g = ambientColor[1];
      var b = ambientColor[2];

      if (r != 0 || g != 0 || b != 0) {
        var color = new Color(r, g, b);
        sceneGraph.add(new AmbientLight(color, 1));
      }
    }
  }
}

// parse Geometry data from FBXTree and return map of BufferGeometries
class GeometryParser {
  // Parse nodes in FBXTree.Objects.Geometry
  parse(deformers) {
    var geometryMap = new Map();

    if (fbxTree.Objects["Geometry"] != null) {
      var geoNodes = fbxTree.Objects["Geometry"];

      for (var nodeID in geoNodes.keys) {
        var relationships = connections[parseInt(nodeID)];
        var geo =
            this.parseGeometry(relationships, geoNodes[nodeID], deformers);

        geometryMap[parseInt(nodeID)] = geo;
      }
    }

    return geometryMap;
  }

  // Parse single node in FBXTree.Objects.Geometry
  parseGeometry(relationships, geoNode, deformers) {
    switch (geoNode["attrType"]) {
      case 'Mesh':
        return this.parseMeshGeometry(relationships, geoNode, deformers);
        break;

      case 'NurbsCurve':
        return this.parseNurbsGeometry(geoNode);
        break;
    }
  }

  // Parse single node mesh geometry in FBXTree.Objects.Geometry
  parseMeshGeometry(relationships, geoNode, deformers) {
    var skeletons = deformers["skeletons"];
    var morphTargets = [];

    List modelNodes = relationships["parents"].map((parent) {
      return fbxTree.Objects["Model"][parent["ID"]];
    }).toList();

    // don't create geometry if it is not associated with any models
    if (modelNodes.length == 0) return;

    var skeleton;
    for (var child in relationships["children"]) {
      if (skeletons[child["ID"]] != null) {
        skeleton = skeletons[child["ID"]];
      }
    }

    relationships["children"].forEach((child) {
      if (deformers["morphTargets"][child["ID"]] != null) {
        morphTargets.add(deformers["morphTargets"][child["ID"]]);
      }
    });

    // Assume one model and get the preRotation from that
    // if there is more than one model associated with the geometry this may cause problems
    Map modelNode = modelNodes[0];

    var transformData = {};

    if (modelNode['RotationOrder'] != null)
      transformData["eulerOrder"] =
          getEulerOrder(modelNode["RotationOrder"]["value"]);
    if (modelNode['InheritType'] != null)
      transformData["inheritType"] =
          parseInt(modelNode["InheritType"]["value"]);

    if (modelNode['GeometricTranslation'] != null)
      transformData["translation"] = modelNode["GeometricTranslation"]["value"];
    if (modelNode['GeometricRotation'] != null)
      transformData["rotation"] = modelNode["GeometricRotation"]["value"];
    if (modelNode['GeometricScaling'] != null)
      transformData["scale"] = modelNode["GeometricScaling"]["value"];

    var transform = generateTransform(transformData);

    return this.genGeometry(geoNode, skeleton, morphTargets, transform);
  }

  // Generate a BufferGeometry from a node in FBXTree.Objects.Geometry
  genGeometry(Map geoNode, skeleton, morphTargets, preTransform) {
    var geo = new BufferGeometry();
    if (geoNode["attrName"] != null) geo.name = geoNode["attrName"];

    var geoInfo = this.parseGeoNode(geoNode, skeleton);
    var buffers = this.genBuffers(geoInfo);

    var positionAttribute = new Float32BufferAttribute(
        Float32Array.fromList(List<double>.from(buffers["vertex"])), 3);

    positionAttribute.applyMatrix4(preTransform);

    geo.setAttribute('position', positionAttribute);

    if (buffers["colors"].length > 0) {
      geo.setAttribute(
          'color', new Float32BufferAttribute(buffers["colors"], 3));
    }

    if (skeleton != null) {
      geo.setAttribute(
          'skinIndex',
          new Uint16BufferAttribute(
              Uint16Array.fromList(List<int>.from(buffers["weightsIndices"])),
              4));

      geo.setAttribute(
          'skinWeight',
          new Float32BufferAttribute(
              Float32Array.fromList(List<double>.from(
                  buffers["vertexWeights"].map((e) => e.toDouble()))),
              4));

      // used later to bind the skeleton to the model
      geo.userData["FBX_Deformer"] = skeleton;
    }

    if (buffers["normal"].length > 0) {
      var normalMatrix = new Matrix3().getNormalMatrix(preTransform);

      var normalAttribute = new Float32BufferAttribute(
          Float32Array.fromList(List<double>.from(buffers["normal"])), 3);
      normalAttribute.applyNormalMatrix(normalMatrix);

      geo.setAttribute('normal', normalAttribute);
    }

    buffers["uvs"].asMap().forEach((i, uvBuffer) {
      // subsequent uv buffers are called 'uv1', 'uv2', ...
      var name = 'uv' + (i + 1).toString();

      // the first uv buffer is just called 'uv'
      if (i == 0) {
        name = 'uv';
      }

      geo.setAttribute(
          name,
          new Float32BufferAttribute(
              Float32Array.fromList(List<double>.from(buffers["uvs"][i])), 2));
    });

    if (geoInfo["material"] != null &&
        geoInfo["material"]["mappingType"] != 'AllSame') {
      // Convert the material indices of each vertex into rendering groups on the geometry.
      var prevMaterialIndex = buffers["materialIndex"][0];
      var startIndex = 0;

      buffers["materialIndex"].asMap().forEach((i, currentIndex) {
        if (currentIndex != prevMaterialIndex) {
          geo.addGroup(startIndex, i - startIndex, prevMaterialIndex);

          prevMaterialIndex = currentIndex;
          startIndex = i;
        }
      });

      // the loop above doesn't add the last group, do that here.
      if (geo.groups.length > 0) {
        var lastGroup = geo.groups[geo.groups.length - 1];
        var lastIndex = lastGroup["start"] + lastGroup["count"];

        if (lastIndex != buffers["materialIndex"].length) {
          geo.addGroup(lastIndex, buffers["materialIndex"].length - lastIndex,
              prevMaterialIndex);
        }
      }

      // case where there are multiple materials but the whole geometry is only
      // using one of them
      if (geo.groups.length == 0) {
        geo.addGroup(0, buffers["materialIndex"].length,
            buffers["materialIndex"][0].toInt());
      }
    }

    this.addMorphTargets(geo, geoNode, morphTargets, preTransform);

    return geo;
  }

  parseGeoNode(Map geoNode, skeleton) {
    var geoInfo = {};

    geoInfo["vertexPositions"] =
        (geoNode["Vertices"] != null) ? geoNode["Vertices"]["a"] : [];
    geoInfo["vertexIndices"] = (geoNode["PolygonVertexIndex"] != null)
        ? geoNode["PolygonVertexIndex"]["a"]
        : [];

    if (geoNode["LayerElementColor"] != null) {
      geoInfo["color"] =
          this.parseVertexColors(geoNode["LayerElementColor"][0]);
    }

    if (geoNode["LayerElementMaterial"] != null) {
      geoInfo["material"] =
          this.parseMaterialIndices(geoNode["LayerElementMaterial"][0]);
    }

    if (geoNode["LayerElementNormal"] != null) {
      geoInfo["normal"] = this.parseNormals(geoNode["LayerElementNormal"][0]);
    }

    if (geoNode["LayerElementUV"] != null) {
      geoInfo["uv"] = [];

      var i = 0;
      while (geoNode["LayerElementUV"][i] != null) {
        if (geoNode["LayerElementUV"][i]["UV"] != null) {
          geoInfo["uv"].add(this.parseUVs(geoNode["LayerElementUV"][i]));
        }

        i++;
      }
    }

    geoInfo["weightTable"] = {};

    if (skeleton != null) {
      geoInfo["skeleton"] = skeleton;

      if (skeleton["rawBones"] != null)
        skeleton["rawBones"].asMap().forEach((i, rawBone) {
          // loop over the bone's vertex indices and weights
          rawBone["indices"].asMap().forEach((j, index) {
            if (geoInfo["weightTable"][index] == null)
              geoInfo["weightTable"][index] = [];

            geoInfo["weightTable"][index].add({
              "id": i,
              "weight": rawBone["weights"][j],
            });
          });
        });
    }

    return geoInfo;
  }

  genBuffers(geoInfo) {
    var buffers = {
      "vertex": [],
      "normal": [],
      "colors": [],
      "uvs": [],
      "materialIndex": [],
      "vertexWeights": [],
      "weightsIndices": [],
    };

    var polygonIndex = 0;
    var faceLength = 0;
    var displayedWeightsWarning = false;

    // these will hold data for a single face
    var facePositionIndexes = [];
    var faceNormals = [];
    var faceColors = [];
    var faceUVs = [];
    var faceWeights = [];
    var faceWeightIndices = [];

    var scope = this;
    geoInfo["vertexIndices"].asMap().forEach((polygonVertexIndex, vertexIndex) {
      var materialIndex;
      var endOfFace = false;

      // Face index and vertex index arrays are combined in a single array
      // A cube with quad faces looks like this:
      // PolygonVertexIndex: *24 {
      //  a: 0, 1, 3, -3, 2, 3, 5, -5, 4, 5, 7, -7, 6, 7, 1, -1, 1, 7, 5, -4, 6, 0, 2, -5
      //  }
      // Negative numbers mark the end of a face - first face here is 0, 1, 3, -3
      // to find index of last vertex bit shift the index: ^ - 1
      if (vertexIndex < 0) {
        vertexIndex = vertexIndex ^ -1; // equivalent to ( x * -1 ) - 1
        endOfFace = true;
      }

      var weightIndices = [];
      var weights = [];

      facePositionIndexes
          .addAll([vertexIndex * 3, vertexIndex * 3 + 1, vertexIndex * 3 + 2]);

      if (geoInfo["color"] != null) {
        var data = getData(
            polygonVertexIndex, polygonIndex, vertexIndex, geoInfo["color"]);

        faceColors.addAll([data[0], data[1], data[2]]);
      }

      if (geoInfo["skeleton"] != null) {
        if (geoInfo["weightTable"][vertexIndex] != null) {
          geoInfo["weightTable"][vertexIndex].forEach((wt) {
            weights.add(wt["weight"]);
            weightIndices.add(wt["id"]);
          });
        }

        if (weights.length > 4) {
          if (!displayedWeightsWarning) {
            print(
                'THREE.FBXLoader: Vertex has more than 4 skinning weights assigned to vertex. Deleting additional weights.');
            displayedWeightsWarning = true;
          }

          var wIndex = [0, 0, 0, 0];
          var Weight = [0, 0, 0, 0];

          weights.asMap().forEach((weightIndex, weight) {
            var currentWeight = weight;
            var currentIndex = weightIndices[weightIndex];

            var comparedWeightArray = Weight;

            Weight.asMap().forEach((comparedWeightIndex, comparedWeight) {
              if (currentWeight > comparedWeight) {
                comparedWeightArray[comparedWeightIndex] = currentWeight;
                currentWeight = comparedWeight;

                var tmp = wIndex[comparedWeightIndex];
                wIndex[comparedWeightIndex] = currentIndex;
                currentIndex = tmp;
              }
            });
          });

          weightIndices = wIndex;
          weights = Weight;
        }

        // if the weight array is shorter than 4 pad with 0s
        while (weights.length < 4) {
          weights.add(0);
          weightIndices.add(0);
        }

        for (var i = 0; i < 4; ++i) {
          faceWeights.add(weights[i]);
          faceWeightIndices.add(weightIndices[i]);
        }
      }

      if (geoInfo["normal"] != null) {
        var data = getData(
            polygonVertexIndex, polygonIndex, vertexIndex, geoInfo["normal"]);

        faceNormals.addAll([data[0], data[1], data[2]]);
      }

      if (geoInfo["material"] != null &&
          geoInfo["material"]["mappingType"] != 'AllSame') {
        materialIndex = getData(polygonVertexIndex, polygonIndex, vertexIndex,
            geoInfo["material"])[0];
      }

      if (geoInfo["uv"] != null) {
        geoInfo["uv"].asMap().forEach((i, uv) {
          var data = getData(polygonVertexIndex, polygonIndex, vertexIndex, uv);

          if (faceUVs.length == i) {
            faceUVs.add([]);
          }

          faceUVs[i].add(data[0]);
          faceUVs[i].add(data[1]);
        });
      }

      faceLength++;

      if (endOfFace) {
        scope.genFace(
            buffers,
            geoInfo,
            facePositionIndexes,
            materialIndex,
            faceNormals,
            faceColors,
            faceUVs,
            faceWeights,
            faceWeightIndices,
            faceLength);

        polygonIndex++;
        faceLength = 0;

        // reset arrays for the next face
        facePositionIndexes = [];
        faceNormals = [];
        faceColors = [];
        faceUVs = [];
        faceWeights = [];
        faceWeightIndices = [];
      }
    });

    return buffers;
  }

  // Generate data for a single face in a geometry. If the face is a quad then split it into 2 tris
  genFace(
      Map buffers,
      Map geoInfo,
      facePositionIndexes,
      materialIndex,
      faceNormals,
      faceColors,
      faceUVs,
      faceWeights,
      faceWeightIndices,
      faceLength) {
    for (var i = 2; i < faceLength; i++) {
      buffers["vertex"].add(geoInfo["vertexPositions"][facePositionIndexes[0]]);
      buffers["vertex"].add(geoInfo["vertexPositions"][facePositionIndexes[1]]);
      buffers["vertex"].add(geoInfo["vertexPositions"][facePositionIndexes[2]]);

      buffers["vertex"]
          .add(geoInfo["vertexPositions"][facePositionIndexes[(i - 1) * 3]]);
      buffers["vertex"].add(
          geoInfo["vertexPositions"][facePositionIndexes[(i - 1) * 3 + 1]]);
      buffers["vertex"].add(
          geoInfo["vertexPositions"][facePositionIndexes[(i - 1) * 3 + 2]]);

      buffers["vertex"]
          .add(geoInfo["vertexPositions"][facePositionIndexes[i * 3]]);
      buffers["vertex"]
          .add(geoInfo["vertexPositions"][facePositionIndexes[i * 3 + 1]]);
      buffers["vertex"]
          .add(geoInfo["vertexPositions"][facePositionIndexes[i * 3 + 2]]);

      if (geoInfo["skeleton"] != null) {
        buffers["vertexWeights"].add(faceWeights[0]);
        buffers["vertexWeights"].add(faceWeights[1]);
        buffers["vertexWeights"].add(faceWeights[2]);
        buffers["vertexWeights"].add(faceWeights[3]);

        buffers["vertexWeights"].add(faceWeights[(i - 1) * 4]);
        buffers["vertexWeights"].add(faceWeights[(i - 1) * 4 + 1]);
        buffers["vertexWeights"].add(faceWeights[(i - 1) * 4 + 2]);
        buffers["vertexWeights"].add(faceWeights[(i - 1) * 4 + 3]);

        buffers["vertexWeights"].add(faceWeights[i * 4]);
        buffers["vertexWeights"].add(faceWeights[i * 4 + 1]);
        buffers["vertexWeights"].add(faceWeights[i * 4 + 2]);
        buffers["vertexWeights"].add(faceWeights[i * 4 + 3]);

        buffers["weightsIndices"].add(faceWeightIndices[0]);
        buffers["weightsIndices"].add(faceWeightIndices[1]);
        buffers["weightsIndices"].add(faceWeightIndices[2]);
        buffers["weightsIndices"].add(faceWeightIndices[3]);

        buffers["weightsIndices"].add(faceWeightIndices[(i - 1) * 4]);
        buffers["weightsIndices"].add(faceWeightIndices[(i - 1) * 4 + 1]);
        buffers["weightsIndices"].add(faceWeightIndices[(i - 1) * 4 + 2]);
        buffers["weightsIndices"].add(faceWeightIndices[(i - 1) * 4 + 3]);

        buffers["weightsIndices"].add(faceWeightIndices[i * 4]);
        buffers["weightsIndices"].add(faceWeightIndices[i * 4 + 1]);
        buffers["weightsIndices"].add(faceWeightIndices[i * 4 + 2]);
        buffers["weightsIndices"].add(faceWeightIndices[i * 4 + 3]);
      }

      if (geoInfo["color"] != null) {
        buffers["colors"].add(faceColors[0]);
        buffers["colors"].add(faceColors[1]);
        buffers["colors"].add(faceColors[2]);

        buffers["colors"].add(faceColors[(i - 1) * 3]);
        buffers["colors"].add(faceColors[(i - 1) * 3 + 1]);
        buffers["colors"].add(faceColors[(i - 1) * 3 + 2]);

        buffers["colors"].add(faceColors[i * 3]);
        buffers["colors"].add(faceColors[i * 3 + 1]);
        buffers["colors"].add(faceColors[i * 3 + 2]);
      }

      if (geoInfo["material"] != null &&
          geoInfo["material"]["mappingType"] != 'AllSame') {
        buffers["materialIndex"].add(materialIndex);
        buffers["materialIndex"].add(materialIndex);
        buffers["materialIndex"].add(materialIndex);
      }

      if (geoInfo["normal"] != null) {
        buffers["normal"].add(faceNormals[0]);
        buffers["normal"].add(faceNormals[1]);
        buffers["normal"].add(faceNormals[2]);

        buffers["normal"].add(faceNormals[(i - 1) * 3]);
        buffers["normal"].add(faceNormals[(i - 1) * 3 + 1]);
        buffers["normal"].add(faceNormals[(i - 1) * 3 + 2]);

        buffers["normal"].add(faceNormals[i * 3]);
        buffers["normal"].add(faceNormals[i * 3 + 1]);
        buffers["normal"].add(faceNormals[i * 3 + 2]);
      }

      if (geoInfo["uv"] != null) {
        geoInfo["uv"].asMap().forEach((j, uv) {
          if (buffers["uvs"].length == j) buffers["uvs"].add([]);

          buffers["uvs"][j].add(faceUVs[j][0]);
          buffers["uvs"][j].add(faceUVs[j][1]);

          buffers["uvs"][j].add(faceUVs[j][(i - 1) * 2]);
          buffers["uvs"][j].add(faceUVs[j][(i - 1) * 2 + 1]);

          buffers["uvs"][j].add(faceUVs[j][i * 2]);
          buffers["uvs"][j].add(faceUVs[j][i * 2 + 1]);
        });
      }
    }
  }

  addMorphTargets(parentGeo, parentGeoNode, morphTargets, preTransform) {
    if (morphTargets.length == 0) return;

    parentGeo.morphTargetsRelative = true;

    parentGeo.morphAttributes.position = [];
    // parentGeo.morphAttributes.normal = []; // not implemented

    var scope = this;
    morphTargets.forEach((morphTarget) {
      morphTarget.rawTargets.forEach((rawTarget) {
        var morphGeoNode = fbxTree.Objects["Geometry"][rawTarget.geoID];

        if (morphGeoNode != null) {
          scope.genMorphGeometry(parentGeo, parentGeoNode, morphGeoNode,
              preTransform, rawTarget.name);
        }
      });
    });
  }

  // a morph geometry node is similar to a standard  node, and the node is also contained
  // in FBXTree.Objects.Geometry, however it can only have attributes for position, normal
  // and a special attribute Index defining which vertices of the original geometry are affected
  // Normal and position attributes only have data for the vertices that are affected by the morph
  genMorphGeometry(parentGeo, parentGeoNode, morphGeoNode, preTransform, name) {
    var vertexIndices = (parentGeoNode.PolygonVertexIndex != null)
        ? parentGeoNode.PolygonVertexIndex.a
        : [];

    var morphPositionsSparse =
        (morphGeoNode.Vertices != null) ? morphGeoNode.Vertices.a : [];
    var indices = (morphGeoNode.Indexes != null) ? morphGeoNode.Indexes.a : [];

    var length = parentGeo.attributes.position.count * 3;
    var morphPositions = new Float32Array(length);

    for (var i = 0; i < indices.length; i++) {
      var morphIndex = indices[i] * 3;

      morphPositions[morphIndex] = morphPositionsSparse[i * 3];
      morphPositions[morphIndex + 1] = morphPositionsSparse[i * 3 + 1];
      morphPositions[morphIndex + 2] = morphPositionsSparse[i * 3 + 2];
    }

    // TODO: add morph normal support
    var morphGeoInfo = {
      "vertexIndices": vertexIndices,
      "vertexPositions": morphPositions,
    };

    var morphBuffers = this.genBuffers(morphGeoInfo);

    var positionAttribute = new Float32BufferAttribute(morphBuffers.vertex, 3);
    positionAttribute.name = name ?? morphGeoNode.attrName;

    positionAttribute.applyMatrix4(preTransform);

    parentGeo.morphAttributes.position.push(positionAttribute);
  }

  // Parse normal from FBXTree.Objects.Geometry.LayerElementNormal if it exists
  parseNormals(Map NormalNode) {
    var mappingType = NormalNode["MappingInformationType"];
    var referenceType = NormalNode["ReferenceInformationType"];
    var buffer = NormalNode["Normals"]["a"];
    var indexBuffer = [];
    if (referenceType == 'IndexToDirect') {
      if (NormalNode["NormalIndex"] != null) {
        indexBuffer = NormalNode["NormalIndex"]["a"];
      } else if (NormalNode["NormalsIndex"] != null) {
        indexBuffer = NormalNode["NormalsIndex"]["a"];
      }
    }

    return {
      "dataSize": 3,
      "buffer": buffer,
      "indices": indexBuffer,
      "mappingType": mappingType,
      "referenceType": referenceType
    };
  }

  // Parse UVs from FBXTree.Objects.Geometry.LayerElementUV if it exists
  parseUVs(Map UVNode) {
    var mappingType = UVNode["MappingInformationType"];
    var referenceType = UVNode["ReferenceInformationType"];
    var buffer = UVNode["UV"]["a"];
    var indexBuffer = [];
    if (referenceType == 'IndexToDirect') {
      indexBuffer = UVNode["UVIndex"]["a"];
    }

    return {
      "dataSize": 2,
      "buffer": buffer,
      "indices": indexBuffer,
      "mappingType": mappingType,
      "referenceType": referenceType
    };
  }

  // Parse Vertex Colors from FBXTree.Objects.Geometry.LayerElementColor if it exists
  parseVertexColors(ColorNode) {
    var mappingType = ColorNode.MappingInformationType;
    var referenceType = ColorNode.ReferenceInformationType;
    var buffer = ColorNode.Colors.a;
    var indexBuffer = [];
    if (referenceType == 'IndexToDirect') {
      indexBuffer = ColorNode.ColorIndex.a;
    }

    return {
      "dataSize": 4,
      "buffer": buffer,
      "indices": indexBuffer,
      "mappingType": mappingType,
      "referenceType": referenceType
    };
  }

  // Parse mapping and material data in FBXTree.Objects.Geometry.LayerElementMaterial if it exists
  parseMaterialIndices(Map MaterialNode) {
    var mappingType = MaterialNode["MappingInformationType"];
    var referenceType = MaterialNode["ReferenceInformationType"];

    if (mappingType == 'NoMappingInformation') {
      return {
        "dataSize": 1,
        "buffer": [0],
        "indices": [0],
        "mappingType": 'AllSame',
        "referenceType": referenceType
      };
    }

    var materialIndexBuffer = MaterialNode["Materials"]["a"];

    // Since materials are stored as indices, there's a bit of a mismatch between FBX and what
    // we expect.So we create an intermediate buffer that points to the index in the buffer,
    // for conforming with the other functions we've written for other data.
    var materialIndices = [];

    for (var i = 0; i < materialIndexBuffer.length; ++i) {
      materialIndices.add(i);
    }

    return {
      "dataSize": 1,
      "buffer": materialIndexBuffer,
      "indices": materialIndices,
      "mappingType": mappingType,
      "referenceType": referenceType
    };
  }

  // Generate a NurbGeometry from a node in FBXTree.Objects.Geometry
  parseNurbsGeometry(geoNode) {
    if (NURBSCurve == null) {
      print(
          'THREE.FBXLoader: The loader relies on NURBSCurve for any nurbs present in the model. Nurbs will show up as empty geometry.');
      return new BufferGeometry();
    }

    var order = int.parse(geoNode.Order);

    if (order == null) {
      print(
          'THREE.FBXLoader: Invalid Order ${geoNode.Order} given for geometry ID: ${geoNode.id}');
      return BufferGeometry();
    }

    var degree = order - 1;

    var knots = geoNode.KnotVector.a;
    var controlPoints = [];
    var pointsValues = geoNode.Points.a;

    for (var i = 0, l = pointsValues.length; i < l; i += 4) {
      controlPoints.add(Vector4().fromArray(pointsValues, i));
    }

    var startKnot, endKnot;

    if (geoNode.Form == 'Closed') {
      controlPoints.add(controlPoints[0]);
    } else if (geoNode.Form == 'Periodic') {
      startKnot = degree;
      endKnot = knots.length - 1 - startKnot;

      for (var i = 0; i < degree; ++i) {
        controlPoints.add(controlPoints[i]);
      }
    }

    var curve =
        new NURBSCurve(degree, knots, controlPoints, startKnot, endKnot);
    var points = curve.getPoints(controlPoints.length * 12);

    return new BufferGeometry().setFromPoints(points);
  }
}

// parse animation data from FBXTree
class AnimationParser {
  // take raw animation clips and turn them into three.js animation clips
  parse() {
    var animationClips = [];

    var rawClips = this.parseClips();

    if (rawClips != null) {
      for (var key in rawClips.keys) {
        var rawClip = rawClips[key];

        var clip = this.addClip(rawClip);

        animationClips.add(clip);
      }
    }

    return animationClips;
  }

  parseClips() {
    // since the actual transformation data is stored in FBXTree.Objects.AnimationCurve,
    // if this is null we can safely assume there are no animations
    if (fbxTree.Objects["AnimationCurve"] == null) return null;

    var curveNodesMap = this.parseAnimationCurveNodes();

    this.parseAnimationCurves(curveNodesMap);

    var layersMap = this.parseAnimationLayers(curveNodesMap);
    var rawClips = this.parseAnimStacks(layersMap);

    return rawClips;
  }

  // parse nodes in FBXTree.Objects.AnimationCurveNode
  // each AnimationCurveNode holds data for an animation transform for a model (e.g. left arm rotation )
  // and is referenced by an AnimationLayer
  parseAnimationCurveNodes() {
    var rawCurveNodes = fbxTree.Objects["AnimationCurveNode"];

    var curveNodesMap = new Map();

    for (var nodeID in rawCurveNodes.keys) {
      var rawCurveNode = rawCurveNodes[nodeID];

      if (RegExp(r'S|R|T|DeformPercent').hasMatch(rawCurveNode["attrName"])) {
        var curveNode = {
          "id": rawCurveNode["id"],
          "attr": rawCurveNode["attrName"],
          "curves": {},
        };

        curveNodesMap[curveNode["id"]] = curveNode;
      }
    }

    return curveNodesMap;
  }

  // parse nodes in FBXTree.Objects.AnimationCurve and connect them up to
  // previously parsed AnimationCurveNodes. Each AnimationCurve holds data for a single animated
  // axis ( e.g. times and values of x rotation)
  parseAnimationCurves(curveNodesMap) {
    var rawCurves = fbxTree.Objects["AnimationCurve"];

    // TODO: Many values are identical up to roundoff error, but won't be optimised
    // e.g. position times: [0, 0.4, 0. 8]
    // position values: [7.23538335023477e-7, 93.67518615722656, -0.9982695579528809, 7.23538335023477e-7, 93.67518615722656, -0.9982695579528809, 7.235384487103147e-7, 93.67520904541016, -0.9982695579528809]
    // clearly, this should be optimised to
    // times: [0], positions [7.23538335023477e-7, 93.67518615722656, -0.9982695579528809]
    // this shows up in nearly every FBX file, and generally time array is length > 100

    for (var nodeID in rawCurves.keys) {
      var animationCurve = {
        "id": rawCurves[nodeID]["id"],
        "times": rawCurves[nodeID]["KeyTime"]["a"]
            .map(convertFBXTimeToSeconds)
            .toList(),
        "values": rawCurves[nodeID]["KeyValueFloat"]["a"],
      };

      var relationships = connections[animationCurve["id"]];

      if (relationships != null) {
        var animationCurveID = relationships["parents"][0]["ID"];
        var animationCurveRelationship =
            relationships["parents"][0]["relationship"];

        if (RegExp(r'X').hasMatch(animationCurveRelationship)) {
          curveNodesMap[animationCurveID]["curves"]['x'] = animationCurve;
        } else if (RegExp(r'Y').hasMatch(animationCurveRelationship)) {
          curveNodesMap[animationCurveID]["curves"]['y'] = animationCurve;
        } else if (RegExp(r'Z').hasMatch(animationCurveRelationship)) {
          curveNodesMap[animationCurveID]["curves"]['z'] = animationCurve;
        } else if (RegExp(r'd|DeformPercent')
                .hasMatch(animationCurveRelationship) &&
            curveNodesMap.has(animationCurveID)) {
          curveNodesMap[animationCurveID]["curves"]['morph'] = animationCurve;
        }
      }
    }
  }

  // parse nodes in FBXTree.Objects.AnimationLayer. Each layers holds references
  // to various AnimationCurveNodes and is referenced by an AnimationStack node
  // note: theoretically a stack can have multiple layers, however in practice there always seems to be one per stack
  Map parseAnimationLayers(curveNodesMap) {
    var rawLayers = fbxTree.Objects["AnimationLayer"];
    Map layersMap = {};

    for (var nodeID in rawLayers.keys) {
      var layerCurveNodes = [];

      var connection = connections[int.parse(nodeID.toString())];

      if (connection != null) {
        // all the animationCurveNodes used in the layer
        var children = connection["children"];

        children.asMap().forEach((i, child) {
          if (curveNodesMap.containsKey(child["ID"])) {
            var curveNode = curveNodesMap[child["ID"]];

            // check that the curves are defined for at least one axis, otherwise ignore the curveNode
            if (curveNode["curves"]["x"] != null ||
                curveNode["curves"]["y"] != null ||
                curveNode["curves"]["z"] != null) {
              var modelID = connections[child["ID"]]["parents"].where((parent) {
                return parent["relationship"] != null;
              }).toList()[0]["ID"];

              if (modelID != null) {
                var rawModel = fbxTree.Objects["Model"][modelID];

                if (rawModel == null) {
                  print(
                      'THREE.FBXLoader: Encountered a unused curve. ${child}');
                  return;
                }

                var node = {
                  "modelName": rawModel["attrName"] != null
                      ? PropertyBinding.sanitizeNodeName(rawModel["attrName"])
                      : '',
                  "ID": rawModel["id"],
                  "initialPosition": [0, 0, 0],
                  "initialRotation": [0, 0, 0],
                  "initialScale": [1, 1, 1],
                };

                sceneGraph.traverse((child) {
                  if (child.id == rawModel["id"]) {
                    node["transform"] = child.matrix;

                    if (child.userData["transformData"] != null)
                      node["eulerOrder"] =
                          child.userData["transformData"]["eulerOrder"];
                  }
                });

                if (node["transform"] == null)
                  node["transform"] = new Matrix4();

                // if the animated model is pre rotated, we'll have to apply the pre rotations to every
                // animation value as well
                if (rawModel.keys.contains('PreRotation'))
                  node["preRotation"] = rawModel["PreRotation"]["value"];
                if (rawModel.keys.contains('PostRotation'))
                  node["postRotation"] = rawModel["PostRotation"]["value"];

                layerCurveNodes.add(node);
              }

              if (layerCurveNodes[i] != null)
                layerCurveNodes[i][curveNode["attr"]] = curveNode;
            } else if (curveNode.curves.morph != null) {
              if (layerCurveNodes[i] == null) {
                var deformerID =
                    connections[child["ID"]].parents.filter((parent) {
                  return parent.relationship != null;
                })[0].ID;

                var morpherID = connections[deformerID].parents[0].ID;
                var geoID = connections[morpherID].parents[0].ID;

                // assuming geometry is not used in more than one model
                var modelID = connections[geoID].parents[0].ID;

                var rawModel = fbxTree.Objects["Model"][modelID];

                var node = {
                  "modelName": rawModel.attrName
                      ? PropertyBinding.sanitizeNodeName(rawModel.attrName)
                      : '',
                  "morphName": fbxTree.Objects["Deformer"][deformerID].attrName,
                };

                layerCurveNodes[i] = node;
              }

              layerCurveNodes[i][curveNode.attr] = curveNode;
            }
          }
        });

        layersMap[int.parse(nodeID.toString())] = layerCurveNodes;
      }
    }

    return layersMap;
  }

  // parse nodes in FBXTree.Objects.AnimationStack. These are the top level node in the animation
  // hierarchy. Each Stack node will be used to create a AnimationClip
  parseAnimStacks(layersMap) {
    var rawStacks = fbxTree.Objects["AnimationStack"];

    // connect the stacks (clips) up to the layers
    var rawClips = {};

    for (var nodeID in rawStacks.keys) {
      var children = connections[int.parse(nodeID.toString())]["children"];

      if (children.length > 1) {
        // it seems like stacks will always be associated with a single layer. But just in case there are files
        // where there are multiple layers per stack, we'll display a warning
        print(
            'THREE.FBXLoader: Encountered an animation stack with multiple layers, this is currently not supported. Ignoring subsequent layers.');
      }

      var layer = layersMap[children[0]["ID"]];

      rawClips[nodeID] = {
        "name": rawStacks[nodeID]["attrName"],
        "layer": layer,
      };
    }

    return rawClips;
  }

  addClip(rawClip) {
    var tracks = [];

    var scope = this;
    rawClip["layer"].forEach((rawTracks) {
      tracks.addAll(scope.generateTracks(rawTracks));
    });
    return new AnimationClip(
        rawClip["name"], -1, List<KeyframeTrack>.from(tracks));
  }

  generateTracks(Map rawTracks) {
    var tracks = [];

    var initialPositionVector3 = new Vector3();
    var initialRotationQuaternion = new Quaternion();
    var initialScaleVector3 = new Vector3();

    if (rawTracks["transform"] != null)
      rawTracks["transform"].decompose(initialPositionVector3,
          initialRotationQuaternion, initialScaleVector3);

    var initialPosition = initialPositionVector3.toArray();
    var initialRotation = new Euler()
        .setFromQuaternion(initialRotationQuaternion, rawTracks["eulerOrder"])
        .toArray();
    var initialScale = initialScaleVector3.toArray();

    if (rawTracks["T"] != null && rawTracks["T"]["curves"].keys.length > 0) {
      var positionTrack = this.generateVectorTrack(rawTracks["modelName"],
          rawTracks["T"]["curves"], initialPosition, 'position');
      if (positionTrack != null) tracks.add(positionTrack);
    }

    if (rawTracks["R"] != null && rawTracks["R"]["curves"].keys.length > 0) {
      var rotationTrack = this.generateRotationTrack(
          rawTracks["modelName"],
          rawTracks["R"]["curves"],
          initialRotation,
          rawTracks["preRotation"],
          rawTracks["postRotation"],
          rawTracks["eulerOrder"]);
      if (rotationTrack != null) tracks.add(rotationTrack);
    }

    if (rawTracks["S"] != null && rawTracks["S"]["curves"].keys.length > 0) {
      var scaleTrack = this.generateVectorTrack(rawTracks["modelName"],
          rawTracks["S"]["curves"], initialScale, 'scale');
      if (scaleTrack != null) tracks.add(scaleTrack);
    }

    if (rawTracks["DeformPercent"] != null) {
      var morphTrack = this.generateMorphTrack(rawTracks);
      if (morphTrack != null) tracks.add(morphTrack);
    }

    return tracks;
  }

  generateVectorTrack(modelName, curves, initialValue, type) {
    var times = this.getTimesForAllAxes(curves);
    var values = this.getKeyframeTrackValues(times, curves, initialValue);

    return new VectorKeyframeTrack('${modelName}.${type}', times, values);
  }

  generateRotationTrack(modelName, Map curves, initialValue, preRotation,
      postRotation, eulerOrder) {
    if (curves["x"] != null) {
      this.interpolateRotations(curves["x"]);
      curves["x"]["values"] = curves["x"]["values"]
          .map((v) => MathUtils.degToRad(v).toDouble())
          .toList();
    }

    if (curves["y"] != null) {
      this.interpolateRotations(curves["y"]);
      curves["y"]["values"] = curves["y"]["values"]
          .map((v) => MathUtils.degToRad(v).toDouble())
          .toList();
    }

    if (curves["z"] != null) {
      this.interpolateRotations(curves["z"]);
      curves["z"]["values"] = curves["z"]["values"]
          .map((v) => MathUtils.degToRad(v).toDouble())
          .toList();
    }

    var times = this.getTimesForAllAxes(curves);
    var values = this.getKeyframeTrackValues(times, curves, initialValue);

    Quaternion? preRotationQuaternion;

    if (preRotation != null) {
      preRotation =
          preRotation.map((v) => MathUtils.degToRad(v).toDouble()).toList();
      preRotation.add(eulerOrder);

      if (preRotation.length == 4 &&
          Euler.RotationOrders.indexOf(preRotation[3]) >= 0) {
        preRotation[3] =
            Euler.RotationOrders.indexOf(preRotation[3]).toDouble();
      }

      var preRotationEuler =
          new Euler().fromArray(List<double>.from(preRotation));
      preRotationQuaternion = new Quaternion().setFromEuler(preRotationEuler);
    }

    if (postRotation != null) {
      postRotation =
          postRotation.map((v) => MathUtils.degToRad(v).toDouble()).toList();
      postRotation.push(eulerOrder);

      postRotation = new Euler().fromArray(postRotation);
      postRotation = new Quaternion().setFromEuler(postRotation).invert();
    }

    var quaternion = new Quaternion();
    var euler = new Euler();

    List<num> quaternionValues =
        List<num>.filled(((values.length / 3) * 4).toInt(), 0.0);

    for (var i = 0; i < values.length; i += 3) {
      euler.set(values[i], values[i + 1], values[i + 2], eulerOrder);

      quaternion.setFromEuler(euler);

      if (preRotationQuaternion != null)
        quaternion.premultiply(preRotationQuaternion);
      if (postRotation != null) quaternion.multiply(postRotation);

      quaternion.toArray(quaternionValues, ((i / 3) * 4).toInt());
    }

    return new QuaternionKeyframeTrack(
        '${modelName}.quaternion', times, quaternionValues);
  }

  generateMorphTrack(rawTracks) {
    var curves = rawTracks.DeformPercent.curves.morph;
    var values = curves.values.map((val) {
      return val / 100;
    }).toList();

    var morphNum = sceneGraph
        .getObjectByName(rawTracks.modelName)
        .morphTargetDictionary[rawTracks.morphName];

    return new NumberKeyframeTrack(
        '${rawTracks.modelName}.morphTargetInfluences[${morphNum}]',
        curves.times,
        values);
  }

  // For all animated objects, times are defined separately for each axis
  // Here we'll combine the times into one sorted array without duplicates
  getTimesForAllAxes(Map curves) {
    var times = [];

    // first join together the times for each axis, if defined
    if (curves["x"] != null) times.addAll(curves["x"]["times"]);
    if (curves["y"] != null) times.addAll(curves["y"]["times"]);
    if (curves["z"] != null) times.addAll(curves["z"]["times"]);

    // then sort them
    times.sort((a, b) {
      return a - b > 0 ? 1 : -1;
    });

    // and remove duplicates
    if (times.length > 1) {
      var targetIndex = 1;
      var lastValue = times[0];
      for (var i = 1; i < times.length; i++) {
        var currentValue = times[i];
        if (currentValue != lastValue) {
          times[targetIndex] = currentValue;
          lastValue = currentValue;
          targetIndex++;
        }
      }

      times = times.sublist(0, targetIndex);
    }

    return times;
  }

  getKeyframeTrackValues(times, Map curves, initialValue) {
    var prevValue = initialValue;

    var values = [];

    var xIndex = -1;
    var yIndex = -1;
    var zIndex = -1;

    times.forEach((time) {
      if (curves["x"] != null)
        xIndex = curves["x"]["times"].toList().indexOf(time);
      if (curves["y"] != null)
        yIndex = curves["y"]["times"].toList().indexOf(time);
      if (curves["z"] != null)
        zIndex = curves["z"]["times"].toList().indexOf(time);

      // if there is an x value defined for this frame, use that
      if (xIndex != -1) {
        var xValue = curves["x"]["values"][xIndex];
        values.add(xValue);
        prevValue[0] = xValue;
      } else {
        // otherwise use the x value from the previous frame
        values.add(prevValue[0]);
      }

      if (yIndex != -1) {
        var yValue = curves["y"]["values"][yIndex];
        values.add(yValue);
        prevValue[1] = yValue;
      } else {
        values.add(prevValue[1]);
      }

      if (zIndex != -1) {
        var zValue = curves["z"]["values"][zIndex];
        values.add(zValue);
        prevValue[2] = zValue;
      } else {
        values.add(prevValue[2]);
      }
    });

    return values;
  }

  // Rotations are defined as Euler angles which can have values  of any size
  // These will be converted to quaternions which don't support values greater than
  // PI, so we'll interpolate large rotations
  interpolateRotations(Map curve) {
    for (var i = 1; i < curve["values"].length; i++) {
      var initialValue = curve["values"][i - 1];
      var valuesSpan = curve["values"][i] - initialValue;

      var absoluteSpan = Math.abs(valuesSpan);

      if (absoluteSpan >= 180) {
        var numSubIntervals = absoluteSpan / 180;

        var step = valuesSpan / numSubIntervals;
        var nextValue = initialValue + step;

        var initialTime = curve["times"][i - 1];
        var timeSpan = curve["times"][i] - initialTime;
        var interval = timeSpan / numSubIntervals;
        var nextTime = initialTime + interval;

        var interpolatedTimes = [];
        var interpolatedValues = [];

        while (nextTime < curve["times"][i]) {
          interpolatedTimes.add(nextTime);
          nextTime += interval;

          interpolatedValues.add(nextValue);
          nextValue += step;
        }

        curve["times"] = inject(curve["times"], i, interpolatedTimes);
        curve["values"] = inject(curve["values"], i, interpolatedValues);
      }
    }
  }
}

// parse an FBX file in ASCII format
class TextParser {
  late int currentIndent;
  late List nodeStack;
  late dynamic currentProp;
  late FBXTree allNodes;
  late String currentPropName;

  getPrevNode() {
    return this.nodeStack[this.currentIndent - 2];
  }

  getCurrentNode() {
    return this.nodeStack[this.currentIndent - 1];
  }

  getCurrentProp() {
    return this.currentProp;
  }

  pushStack(node) {
    this.nodeStack.add(node);
    this.currentIndent += 1;
  }

  popStack() {
    this.nodeStack.removeLast();
    this.currentIndent -= 1;
  }

  setCurrentProp(val, name) {
    this.currentProp = val;
    this.currentPropName = name;
  }

  parse(text) {
    this.currentIndent = 0;

    this.allNodes = new FBXTree();
    this.nodeStack = [];
    this.currentProp = [];
    this.currentPropName = '';

    var scope = this;

    var split = text.split(RegExp(r'[\r\n]+'));

    split.asMap().forEach((i, line) {
      var matchComment = RegExp(r"^[\s\t]*;").hasMatch(line);
      var matchEmpty = RegExp(r"^[\s\t]*$").hasMatch(line);

      if (matchComment || matchEmpty) return;

      var matchBeginning = line.match(
          '^\\t{' + scope.currentIndent.toString() + '}(\\w+):(.*){', '');
      var matchProperty = line.match('^\\t{' +
          (scope.currentIndent.toString()) +
          '}(\\w+):[\\s\\t\\r\\n](.*)');
      var matchEnd =
          line.match('^\\t{' + (scope.currentIndent - 1).toString() + '}}');

      if (matchBeginning) {
        scope.parseNodeBegin(line, matchBeginning);
      } else if (matchProperty) {
        scope.parseNodeProperty(line, matchProperty, split[++i]);
      } else if (matchEnd) {
        scope.popStack();
      } else if (RegExp(r"^[^\s\t}]").hasMatch(line)) {
        // large arrays are split over multiple lines terminated with a ',' character
        // if this is encountered the line needs to be joined to the previous line
        scope.parseNodePropertyContinued(line);
      }
    });

    return this.allNodes;
  }

  parseNodeBegin(line, property) {
    var nodeName = property[1]
        .trim()
        .replaceFirst(RegExp(r'^"'), '')
        .replace(RegExp(r'"$'), '');

    var nodeAttrs = property[2].split(',').map((attr) {
      return attr
          .trim()
          .replaceFirst(RegExp(r'^"'), '')
          .replace(RegExp(r'"$'), '');
    }).toList();

    Map<String, dynamic> node = {"name": nodeName};
    var attrs = this.parseNodeAttr(nodeAttrs);

    Map currentNode = this.getCurrentNode();

    // a top node
    if (this.currentIndent == 0) {
      this.allNodes.add(nodeName, node);
    } else {
      // a subnode

      // if the subnode already exists, append it
      if (currentNode.keys.contains(nodeName)) {
        // special case Pose needs PoseNodes as an array
        if (nodeName == 'PoseNode') {
          currentNode["PoseNode"].add(node);
        } else if (currentNode[nodeName].id != null) {
          currentNode[nodeName] = {};
          currentNode[nodeName][currentNode[nodeName].id] =
              currentNode[nodeName];
        }

        if (attrs.id != '') currentNode[nodeName][attrs.id] = node;
      } else if (attrs.id is num) {
        currentNode[nodeName] = {};
        currentNode[nodeName][attrs.id] = node;
      } else if (nodeName != 'Properties70') {
        if (nodeName == 'PoseNode')
          currentNode[nodeName] = [node];
        else
          currentNode[nodeName] = node;
      }
    }

    if (attrs.id is num) node["id"] = attrs.id;
    if (attrs.name != '') node["attrName"] = attrs.name;
    if (attrs.type != '') node["attrType"] = attrs.type;

    this.pushStack(node);
  }

  parseNodeAttr(attrs) {
    var id = attrs[0];

    if (attrs[0] != '') {
      id = int.parse(attrs[0]);

      if (id == null) {
        id = attrs[0];
      }
    }

    var name = '', type = '';

    if (attrs.length > 1) {
      name = attrs[1].replaceFirst(RegExp(r'^(\w+)::'), '');
      type = attrs[2];
    }

    return {id: id, name: name, type: type};
  }

  parseNodeProperty(line, property, String contentLine) {
    var _regExp = RegExp(r'^"');
    var _regExp2 = RegExp(r'"$');

    var propName =
        property[1].replaceFirst(_regExp, '').replaceFirst(_regExp2, '').trim();
    var propValue =
        property[2].replaceFirst(_regExp, '').replaceFirst(_regExp2, '').trim();

    // for special case: base64 image data follows "Content: ," line
    //	Content: ,
    //	 "/9j/4RDaRXhpZgAATU0A..."
    if (propName == 'Content' && propValue == ',') {
      propValue = contentLine
          .replaceAll(RegExp(r'"'), '')
          .replaceFirst(RegExp(r',$'), '')
          .trim();
    }

    var currentNode = this.getCurrentNode();
    var parentName = currentNode.name;

    if (parentName == 'Properties70') {
      this.parseNodeSpecialProperty(line, propName, propValue);
      return;
    }

    // Connections
    if (propName == 'C') {
      var connProps = propValue.split(',').slice(1);
      var from = int.parse(connProps[0]);
      var to = int.parse(connProps[1]);

      var rest = propValue.split(',').slice(3);

      rest = rest.map((elem) {
        return elem.trim().replace(RegExp(r'^"'), '');
      }).toList();

      propName = 'connections';
      propValue = [from, to];
      append(propValue, rest);

      if (currentNode[propName] == null) {
        currentNode[propName] = [];
      }
    }

    // Node
    if (propName == 'Node') currentNode.id = propValue;

    // connections
    if (currentNode.keys.contains(propName) && currentNode[propName] is List) {
      currentNode[propName].add(propValue);
    } else {
      if (propName != 'a')
        currentNode[propName] = propValue;
      else
        currentNode.a = propValue;
    }

    this.setCurrentProp(currentNode, propName);

    // convert string to array, unless it ends in ',' in which case more will be added to it
    if (propName == 'a' && propValue.slice(-1) != ',') {
      currentNode.a = parseNumberArray(propValue);
    }
  }

  parseNodePropertyContinued(line) {
    var currentNode = this.getCurrentNode();

    currentNode.a += line;

    // if the line doesn't end in ',' we have reached the end of the property value
    // so convert the string to an array
    if (line.slice(-1) != ',') {
      currentNode.a = parseNumberArray(currentNode.a);
    }
  }

  // parse "Property70"
  parseNodeSpecialProperty(line, propName, propValue) {
    // split this
    // P: "Lcl Scaling", "Lcl Scaling", "", "A",1,1,1
    // into array like below
    // ["Lcl Scaling", "Lcl Scaling", "", "A", "1,1,1" ]
    var props = propValue.split('",').map((prop) {
      return prop
          .trim()
          .replace(RegExp(r'^\"'), '')
          .replace(RegExp(r'\s'), '_');
    }).toList();

    var innerPropName = props[0];
    var innerPropType1 = props[1];
    var innerPropType2 = props[2];
    var innerPropFlag = props[3];
    var innerPropValue = props[4];

    // cast values where needed, otherwise leave as strings
    switch (innerPropType1) {
      case 'int':
      case 'enum':
      case 'bool':
      case 'ULongLong':
      case 'double':
      case 'Number':
      case 'FieldOfView':
        innerPropValue = parseFloat(innerPropValue);
        break;

      case 'Color':
      case 'ColorRGB':
      case 'Vector3D':
      case 'Lcl_Translation':
      case 'Lcl_Rotation':
      case 'Lcl_Scaling':
        innerPropValue = parseNumberArray(innerPropValue);
        break;
    }

    // CAUTION: these props must append to parent's parent
    this.getPrevNode()[innerPropName] = {
      'type': innerPropType1,
      'type2': innerPropType2,
      'flag': innerPropFlag,
      'value': innerPropValue
    };

    this.setCurrentProp(this.getPrevNode(), innerPropName);
  }
}

// Parse an FBX file in Binary format
class BinaryParser {
  parse(buffer) {
    var reader = new BinaryReader(buffer);
    reader.skip(23); // skip magic 23 bytes

    var version = reader.getUint32();

    if (version < 6400) {
      throw ('THREE.FBXLoader: FBX version not supported, FileVersion: ' +
          version);
    }

    var allNodes = new FBXTree();

    while (!this.endOfContent(reader)) {
      var node = this.parseNode(reader, version);
      if (node != null) allNodes.add(node["name"], node);
    }

    return allNodes;
  }

  // Check if reader has reached the end of content.
  endOfContent(reader) {
    // footer size: 160bytes + 16-byte alignment padding
    // - 16bytes: magic
    // - padding til 16-byte alignment (at least 1byte?)
    //	(seems like some exporters embed fixed 15 or 16bytes?)
    // - 4bytes: magic
    // - 4bytes: version
    // - 120bytes: zero
    // - 16bytes: magic
    if (reader.size() % 16 == 0) {
      return ((reader.getOffset() + 160 + 16) & ~0xf) >= reader.size();
    } else {
      return reader.getOffset() + 160 + 16 >= reader.size();
    }
  }

  // recursively parse nodes until the end of the file is reached
  Map<String, dynamic>? parseNode(reader, version) {
    Map<String, dynamic> node = {};

    // The first three data sizes depends on version.
    var endOffset = (version >= 7500) ? reader.getUint64() : reader.getUint32();
    var numProperties =
        (version >= 7500) ? reader.getUint64() : reader.getUint32();

    (version >= 7500)
        ? reader.getUint64()
        : reader.getUint32(); // the returned propertyListLen is not used

    var nameLen = reader.getUint8();
    var name = reader.getString(nameLen);

    // Regards this node as NULL-record if endOffset is zero
    if (endOffset == 0) return null;

    var propertyList = [];

    for (var i = 0; i < numProperties; i++) {
      propertyList.add(this.parseProperty(reader));
    }

    // Regards the first three elements in propertyList as id, attrName, and attrType
    var id = propertyList.length > 0 ? propertyList[0] : '';
    var attrName = propertyList.length > 1 ? propertyList[1] : '';
    var attrType = propertyList.length > 2 ? propertyList[2] : '';

    // check if this node represents just a single property
    // like (name, 0) set or (name2, [0, 1, 2]) set of {name: 0, name2: [0, 1, 2]}
    node["singleProperty"] =
        (numProperties == 1 && reader.getOffset() == endOffset) ? true : false;

    while (endOffset > reader.getOffset()) {
      var subNode = this.parseNode(reader, version);

      if (subNode != null) this.parseSubNode(name, node, subNode);
    }

    node["propertyList"] = propertyList; // raw property list used by parent

    if (id is num) node["id"] = id;
    if (attrName != '') node["attrName"] = attrName;
    if (attrType != '') node["attrType"] = attrType;
    if (name != '') node["name"] = name;

    return node;
  }

  parseSubNode(name, Map<String, dynamic> node, Map<String, dynamic> subNode) {
    // special case: child node is single property
    if (subNode["singleProperty"] == true) {
      var value = subNode["propertyList"][0];

      if (value is List) {
        node[subNode["name"]] = subNode;

        subNode["a"] = value;
      } else {
        node[subNode["name"]] = value;
      }
    } else if (name == 'Connections' && subNode["name"] == 'C') {
      var array = [];

      subNode["propertyList"].asMap().forEach((i, property) {
        // first Connection is FBX type (OO, OP, etc.). We'll discard these
        if (i != 0) array.add(property);
      });

      if (node["connections"] == null) {
        node["connections"] = [];
      }

      node["connections"].add(array);
    } else if (subNode["name"] == 'Properties70') {
      var keys = subNode.keys;

      keys.forEach((key) {
        node[key] = subNode[key];
      });
    } else if (name == 'Properties70' && subNode["name"] == 'P') {
      String innerPropName = subNode["propertyList"][0];
      var innerPropType1 = subNode["propertyList"][1];
      var innerPropType2 = subNode["propertyList"][2];
      var innerPropFlag = subNode["propertyList"][3];
      var innerPropValue;

      if (innerPropName.indexOf('Lcl ') == 0)
        innerPropName = innerPropName.replaceFirst('Lcl ', 'Lcl_');
      if (innerPropType1.indexOf('Lcl ') == 0)
        innerPropType1 = innerPropType1.replaceFirst('Lcl ', 'Lcl_');

      if (innerPropType1 == 'Color' ||
          innerPropType1 == 'ColorRGB' ||
          innerPropType1 == 'Vector' ||
          innerPropType1 == 'Vector3D' ||
          innerPropType1.indexOf('Lcl_') == 0) {
        innerPropValue = [
          subNode["propertyList"][4],
          subNode["propertyList"][5],
          subNode["propertyList"][6]
        ];
      } else {
        if (subNode["propertyList"].length > 4) {
          innerPropValue = subNode["propertyList"][4];
        }
      }

      // this will be copied to parent, see above
      node[innerPropName] = {
        'type': innerPropType1,
        'type2': innerPropType2,
        'flag': innerPropFlag,
        'value': innerPropValue
      };
    } else if (node[subNode["name"]] == null) {
      if (subNode["id"] is num) {
        node[subNode["name"]] = {};
        node[subNode["name"]][subNode["id"]] = subNode;
      } else {
        node[subNode["name"]] = subNode;
      }
    } else {
      if (subNode["name"] == 'PoseNode') {
        if (!(node[subNode["name"]] is List)) {
          node[subNode["name"]] = [node[subNode["name"]]];
        }

        node[subNode["name"]].add(subNode);
      } else if (node[subNode["name"]][subNode["id"]] == null) {
        if (subNode["id"] != null) {
          node[subNode["name"]][subNode["id"]] = subNode;
        }
      }
    }
  }

  parseProperty(reader) {
    var type = reader.getString(1);
    var length;

    switch (type) {
      case 'C':
        return reader.getBoolean();

      case 'D':
        return reader.getFloat64();

      case 'F':
        return reader.getFloat32();

      case 'I':
        return reader.getInt32();

      case 'L':
        return reader.getInt64();

      case 'R':
        length = reader.getUint32();
        return reader.getArrayBuffer(length);

      case 'S':
        length = reader.getUint32();
        return reader.getString(length);

      case 'Y':
        return reader.getInt16();

      case 'b':
      case 'c':
      case 'd':
      case 'f':
      case 'i':
      case 'l':
        var arrayLength = reader.getUint32();
        var encoding = reader.getUint32(); // 0: non-compressed, 1: compressed
        var compressedLength = reader.getUint32();

        if (encoding == 0) {
          switch (type) {
            case 'b':
            case 'c':
              return reader.getBooleanArray(arrayLength);

            case 'd':
              return reader.getFloat64Array(arrayLength);

            case 'f':
              return reader.getFloat32Array(arrayLength);

            case 'i':
              return reader.getInt32Array(arrayLength);

            case 'l':
              return reader.getInt64Array(arrayLength);
          }
        }

        // https://pub.dev/packages/archive
        // use archive replace fflate.js
        // var data = fflate.unzlibSync( new Uint8Array( reader.getArrayBuffer( compressedLength ) ) ); // eslint-disable-line no-undef

        var data = ZLibDecoder()
            .decodeBytes(reader.getArrayBuffer(compressedLength), verify: true);
        var reader2 = new BinaryReader(data);

        switch (type) {
          case 'b':
          case 'c':
            return reader2.getBooleanArray(arrayLength);

          case 'd':
            return reader2.getFloat64Array(arrayLength);

          case 'f':
            return reader2.getFloat32Array(arrayLength);

          case 'i':
            return reader2.getInt32Array(arrayLength);

          case 'l':
            return reader2.getInt64Array(arrayLength);
        }
        break;

      default:
        throw ('THREE.FBXLoader: Unknown property type ' + type);
    }
  }
}

class BinaryReader {
  late int offset;
  late Uint8List dv;
  late bool littleEndian;

  BinaryReader(buffer, [littleEndian]) {
    this.dv = buffer;
    this.offset = 0;
    this.littleEndian = (littleEndian != null) ? littleEndian : true;
  }

  getOffset() {
    return this.offset;
  }

  size() {
    return this.dv.buffer.lengthInBytes;
  }

  skip(int length) {
    this.offset += length;
  }

  // seems like true/false representation depends on exporter.
  // true: 1 or 'Y'(=0x59), false: 0 or 'T'(=0x54)
  // then sees LSB.
  getBoolean() {
    return (this.getUint8() & 1) == 1;
  }

  getBooleanArray(int size) {
    var a = [];

    for (var i = 0; i < size; i++) {
      a.add(this.getBoolean());
    }

    return a;
  }

  getUint8() {
    var value = this.dv.buffer.asByteData().getUint8(this.offset);
    this.offset += 1;
    return value;
  }

  getInt16() {
    var value = this
        .dv
        .buffer
        .asByteData()
        .getInt16(this.offset, this.littleEndian ? Endian.little : Endian.big);
    this.offset += 2;
    return value;
  }

  getInt32() {
    var value = this
        .dv
        .buffer
        .asByteData()
        .getInt32(this.offset, this.littleEndian ? Endian.little : Endian.big);
    this.offset += 4;
    return value;
  }

  getInt32Array(size) {
    var a = [];

    for (var i = 0; i < size; i++) {
      a.add(this.getInt32());
    }

    return a;
  }

  getUint32() {
    var value = this
        .dv
        .buffer
        .asByteData()
        .getUint32(this.offset, this.littleEndian ? Endian.little : Endian.big);
    this.offset += 4;
    return value;
  }

  // JavaScript doesn't support 64-bit integer so calculate this here
  // 1 << 32 will return 1 so using multiply operation instead here.
  // There's a possibility that this method returns wrong value if the value
  // is out of the range between Number.MAX_SAFE_INTEGER and Number.MIN_SAFE_INTEGER.
  // TODO: safely handle 64-bit integer
  getInt64() {
    var low, high;

    if (this.littleEndian) {
      low = this.getUint32();
      high = this.getUint32();
    } else {
      high = this.getUint32();
      low = this.getUint32();
    }

    // calculate negative value
    if ((high & 0x80000000) > 0) {
      high = ~high & 0xFFFFFFFF;
      low = ~low & 0xFFFFFFFF;

      if (low == 0xFFFFFFFF) high = (high + 1) & 0xFFFFFFFF;

      low = (low + 1) & 0xFFFFFFFF;

      return -(high * 0x100000000 + low);
    }

    return high * 0x100000000 + low;
  }

  getInt64Array(size) {
    var a = [];

    for (var i = 0; i < size; i++) {
      a.add(this.getInt64());
    }

    return a;
  }

  // Note: see getInt64() comment
  getUint64() {
    var low, high;

    if (this.littleEndian) {
      low = this.getUint32();
      high = this.getUint32();
    } else {
      high = this.getUint32();
      low = this.getUint32();
    }

    return high * 0x100000000 + low;
  }

  getFloat32() {
    var value = this.dv.buffer.asByteData().getFloat32(
        this.offset, this.littleEndian ? Endian.little : Endian.big);
    this.offset += 4;
    return value;
  }

  getFloat32Array(size) {
    var a = [];

    for (var i = 0; i < size; i++) {
      a.add(this.getFloat32());
    }

    return a;
  }

  getFloat64() {
    var value = this.dv.buffer.asByteData().getFloat64(
        this.offset, this.littleEndian ? Endian.little : Endian.big);
    this.offset += 8;
    return value;
  }

  getFloat64Array(size) {
    var a = [];

    for (var i = 0; i < size; i++) {
      a.add(this.getFloat64());
    }

    return a;
  }

  Uint8List getArrayBuffer(int size) {
    var value = this.dv.sublist(this.offset, this.offset + size);
    this.offset += size;
    return value;
  }

  getString(size) {
    // note: safari 9 doesn't support Uint8Array.indexOf; create intermediate array instead
    List<int> a = List<int>.filled(size, 0);

    for (var i = 0; i < size; i++) {
      a[i] = this.getUint8();
    }

    var nullByte = a.indexOf(0);
    if (nullByte >= 0) a = a.sublist(0, nullByte);

    return LoaderUtils.decodeText(a);
  }
}

// FBXTree holds a representation of the FBX data, returned by the TextParser ( FBX ASCII format)
// and BinaryParser( FBX Binary format)
class FBXTree {
  Map<String, dynamic> data = {};

  add(key, val) {
    data[key] = val;
  }

  Map<String, dynamic> get Objects => data["Objects"];
  Map<String, dynamic> get Connections => data["Connections"];
  Map<String, dynamic>? get GlobalSettings => data["GlobalSettings"];
}

// ************** UTILITY FUNCTIONS **************

bool isFbxFormatBinary(Uint8List buffer) {
  String CORRECT = 'Kaydara\u0020FBX\u0020Binary\u0020\u0020\0';
  String str = convertArrayBufferToString(buffer, 0, CORRECT.length);

  return buffer.lengthInBytes >= CORRECT.length &&
      "Kaydara FBX Binary" == str.substring(0, 18).trim();
}

isFbxFormatASCII(String text) {
  var CORRECT = [
    'K',
    'a',
    'y',
    'd',
    'a',
    'r',
    'a',
    '\\',
    'F',
    'B',
    'X',
    '\\',
    'B',
    'i',
    'n',
    'a',
    'r',
    'y',
    '\\',
    '\\'
  ];

  var cursor = 0;

  read(offset) {
    var result = text[offset - 1];
    text =
        text.substring((cursor + offset).toInt()); //.slice( cursor + offset );
    cursor++;
    return result;
  }

  for (var i = 0; i < CORRECT.length; ++i) {
    var num = read(1);
    if (num == CORRECT[i]) {
      return false;
    }
  }

  return true;
}

getFbxVersion(text) {
  var versionRegExp = RegExp(r"FBXVersion: (\d+)");
  var match = versionRegExp.firstMatch(text);

  if (versionRegExp.hasMatch(text)) {
    var version = int.parse(match!.group(1)!);
    return version;
  }

  throw ('THREE.FBXLoader: Cannot find the version number for the file given.');
}

// Converts FBX ticks into real time seconds.
convertFBXTimeToSeconds(time) {
  return time / 46186158000;
}

var dataArray = [];

// extracts the data from the correct position in the FBX array based on indexing type
getData(polygonVertexIndex, polygonIndex, vertexIndex, infoObject) {
  var index;

  switch (infoObject["mappingType"]) {
    case 'ByPolygonVertex':
      index = polygonVertexIndex;
      break;
    case 'ByPolygon':
      index = polygonIndex;
      break;
    case 'ByVertice':
      index = vertexIndex;
      break;
    case 'AllSame':
      index = infoObject.indices[0];
      break;
    default:
      print('THREE.FBXLoader: unknown attribute mapping type ' +
          infoObject["mappingType"]);
  }

  if (infoObject["referenceType"] == 'IndexToDirect')
    index = infoObject["indices"][index];

  var from = index * infoObject["dataSize"];
  var to = from + infoObject["dataSize"];

  return slice(dataArray, infoObject["buffer"], from, to);
}

var tempEuler = new Euler();
var tempVec = new Vector3();

// generate transformation from FBX transform data
// ref: https://help.autodesk.com/view/FBX/2017/ENU/?guid=__files_GUID_10CDD63C_79C1_4F2D_BB28_AD2BE65A02ED_htm
// ref: http://docs.autodesk.com/FBX/2014/ENU/FBX-SDK-Documentation/index.html?url=cpp_ref/_transformations_2main_8cxx-example.html,topicNumber=cpp_ref__transformations_2main_8cxx_example_htmlfc10a1e1-b18d-4e72-9dc0-70d0f1959f5e
generateTransform(Map transformData) {
  var lTranslationM = new Matrix4();
  var lPreRotationM = new Matrix4();
  var lRotationM = new Matrix4();
  var lPostRotationM = new Matrix4();

  var lScalingM = new Matrix4();
  var lScalingPivotM = new Matrix4();
  var lScalingOffsetM = new Matrix4();
  var lRotationOffsetM = new Matrix4();
  var lRotationPivotM = new Matrix4();

  var lParentGX = new Matrix4();
  var lParentLX = new Matrix4();
  var lGlobalT = new Matrix4();

  var inheritType =
      (transformData["inheritType"] != null) ? transformData["inheritType"] : 0;

  if (transformData["translation"] != null)
    lTranslationM.setPosition(tempVec.fromArray(transformData["translation"]));

  if (transformData["preRotation"] != null) {
    List<double> array = List<double>.from(transformData["preRotation"]
        .map((e) => MathUtils.degToRad(e).toDouble())
        .toList());
    array.add(THREE.Euler.RotationOrders
        .indexOf(transformData["eulerOrder"])
        .toDouble());
    lPreRotationM.makeRotationFromEuler(tempEuler.fromArray(array));
  }

  if (transformData["rotation"] != null) {
    List<double> array = List<double>.from(transformData["rotation"]
        .map((e) => MathUtils.degToRad(e).toDouble())
        .toList());
    array.add(THREE.Euler.RotationOrders
        .indexOf(transformData["eulerOrder"])
        .toDouble());
    lRotationM.makeRotationFromEuler(tempEuler.fromArray(array));
  }

  if (transformData["postRotation"] != null) {
    List<double> array = List<double>.from(
        transformData["postRotation"].map((e) => MathUtils.degToRad).toList());
    array.add(THREE.Euler.RotationOrders
        .indexOf(transformData["eulerOrder"])
        .toDouble());
    lPostRotationM.makeRotationFromEuler(tempEuler.fromArray(array));
    lPostRotationM.invert();
  }

  if (transformData["scale"] != null)
    lScalingM.scale(tempVec.fromArray(transformData["scale"]));

  // Pivots and offsets
  if (transformData["scalingOffset"] != null)
    lScalingOffsetM
        .setPosition(tempVec.fromArray(transformData["scalingOffset"]));
  if (transformData["scalingPivot"] != null)
    lScalingPivotM
        .setPosition(tempVec.fromArray(transformData["scalingPivot"]));
  if (transformData["rotationOffset"] != null)
    lRotationOffsetM
        .setPosition(tempVec.fromArray(transformData["rotationOffset"]));
  if (transformData["rotationPivot"] != null)
    lRotationPivotM
        .setPosition(tempVec.fromArray(transformData["rotationPivot"]));

  // parent transform
  if (transformData["parentMatrixWorld"] != null) {
    lParentLX.copy(transformData["parentMatrix"]);
    lParentGX.copy(transformData["parentMatrixWorld"]);
  }

  var lLRM =
      lPreRotationM.clone().multiply(lRotationM).multiply(lPostRotationM);
  // Global Rotation
  var lParentGRM = new Matrix4();
  lParentGRM.extractRotation(lParentGX);

  // Global Shear*Scaling
  var lParentTM = new Matrix4();
  lParentTM.copyPosition(lParentGX);

  var lParentGRSM = lParentTM.clone().invert().multiply(lParentGX);
  var lParentGSM = lParentGRM.clone().invert().multiply(lParentGRSM);
  var lLSM = lScalingM;

  var lGlobalRS = new Matrix4();

  if (inheritType == 0) {
    lGlobalRS
        .copy(lParentGRM)
        .multiply(lLRM)
        .multiply(lParentGSM)
        .multiply(lLSM);
  } else if (inheritType == 1) {
    lGlobalRS
        .copy(lParentGRM)
        .multiply(lParentGSM)
        .multiply(lLRM)
        .multiply(lLSM);
  } else {
    var lParentLSM =
        new Matrix4().scale(new Vector3().setFromMatrixScale(lParentLX));
    var lParentLSM_inv = lParentLSM.clone().invert();
    var lParentGSM_noLocal = lParentGSM.clone().multiply(lParentLSM_inv);

    lGlobalRS
        .copy(lParentGRM)
        .multiply(lLRM)
        .multiply(lParentGSM_noLocal)
        .multiply(lLSM);
  }

  var lRotationPivotM_inv = lRotationPivotM.clone().invert();
  var lScalingPivotM_inv = lScalingPivotM.clone().invert();
  // Calculate the local transform matrix
  var lTransform = lTranslationM
      .clone()
      .multiply(lRotationOffsetM)
      .multiply(lRotationPivotM)
      .multiply(lPreRotationM)
      .multiply(lRotationM)
      .multiply(lPostRotationM)
      .multiply(lRotationPivotM_inv)
      .multiply(lScalingOffsetM)
      .multiply(lScalingPivotM)
      .multiply(lScalingM)
      .multiply(lScalingPivotM_inv);

  var lLocalTWithAllPivotAndOffsetInfo = new Matrix4().copyPosition(lTransform);

  var lGlobalTranslation =
      lParentGX.clone().multiply(lLocalTWithAllPivotAndOffsetInfo);
  lGlobalT.copyPosition(lGlobalTranslation);

  lTransform = lGlobalT.clone().multiply(lGlobalRS);

  // from global to local
  lTransform.premultiply(lParentGX.invert());

  return lTransform;
}

// Returns the three.js intrinsic Euler order corresponding to FBX extrinsic Euler order
// ref: http://help.autodesk.com/view/FBX/2017/ENU/?guid=__cpp_ref_class_fbx_euler_html
getEulerOrder(order) {
  order = order ?? 0;

  var enums = [
    'ZYX', // -> XYZ extrinsic
    'YZX', // -> XZY extrinsic
    'XZY', // -> YZX extrinsic
    'ZXY', // -> YXZ extrinsic
    'YXZ', // -> ZXY extrinsic
    'XYZ', // -> ZYX extrinsic
    //'SphericXYZ', // not possible to support
  ];

  if (order == 6) {
    print(
        'THREE.FBXLoader: unsupported Euler Order: Spherical XYZ. Animations and rotations may be incorrect.');
    return enums[0];
  }

  return enums[order];
}

// Parses comma separated list of numbers and returns them an array.
// Used internally by the TextParser
parseNumberArray(value) {
  var array = value.split(',').map((val) {
    return parseFloat(val);
  }).toList();

  return array;
}

convertArrayBufferToString(Uint8List buffer, [int? from, int? to]) {
  if (from == null) from = 0;
  if (to == null) to = buffer.lengthInBytes;

  var str =
      LoaderUtils.decodeText(Uint8List.view(buffer.buffer, from, to).toList());

  return str;
}

append(a, b) {
  for (var i = 0, j = a.length, l = b.length; i < l; i++, j++) {
    a[j] = b[i];
  }
}

slice(a, b, from, to) {
  for (var i = from, j = 0; i < to; i++, j++) {
    if (a.length == j) {
      a.add(b[i]);
    }
  }

  return a;
}

// inject array a2 into array a1 at index
inject(a1, index, a2) {
  return a1.slice(0, index).concat(a2).concat(a1.slice(index));
}

int? parseInt(v) {
  return int.tryParse(v.toString());
}
