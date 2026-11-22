// This object is specifically to generate cheap trees with transparent textures
import 'package:three_js/three_js.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'dart:math' as math;

import '../asset_pack.dart';

class Tree {
  static Map textures={};

  /// Registered wind ShaderMaterials. Only populated for trees created with
  /// windspeed > 0. Call Tree.updateWind(delta) once per frame.
  static final List<THREE.ShaderMaterial> windMaterials = [];

  static void init() {
    textures = {};
    windMaterials.clear();
  }

  /// Advance the wind time uniform on every registered foliage material.
  /// Call this from your game-loop update, e.g.: Tree.updateWind(frameTime);
  static void updateWind(double delta) {
    for (final mat in windMaterials) {
      final uniforms = mat.uniforms;
      if (uniforms == null) continue;
      final speed   = (uniforms['u_windSpeed']?['value'] ?? 1.0) as double;
      final current = (uniforms['u_windTime']?['value']  ?? 0.0) as double;
      uniforms['u_windTime']!['value'] = current + speed * delta;
    }
  }


  static  createTree(leafpaths,{spreadytapertop=1.0,spreadx=1.0, spready=1.0,  spreadz=1.0,leafspritespertree=64, leafspritescale=1.5,treehollowness=1.0,useplanes=true,treepath,randomroll=0.1,windspeed=0.0}) async {
    var trunkSource;
    if (treepath!=null) {
      final gltf = await THREE.GLTFLoader().fromAsset(treepath);
      final treeScene = gltf!.scene;

      trunkSource = treeScene.getObjectByName('trunk');
      // final foliageSource = treeScene.getObjectByName('foliage');

      if (trunkSource is! THREE.Mesh) { //|| foliageSource is! THREE.Mesh) {
        throw StateError('tree.glb is missing trunk or foliage nodes.');
      }
    } else
      trunkSource=null;


    final trunkMaterial = THREE.MeshBasicMaterial.fromMap({
      'color': 0x000000,
    });

    var leaftextures=[];
    for (var leafpathi in leafpaths) {
      var leafpath;
      var leafscale;
      if (leafpathi is List) {
        leafpath = leafpathi[0];
        leafscale = leafpathi[1];
      } else {
        leafpath=leafpathi;
        leafscale=leafspritescale;
      }

      final leafTexture;
      if (!textures.containsKey(leafpath)) {
        leafTexture = await  AssetPack.loadTexture(leafpath);//await THREE.TextureLoader().fromAsset(
          //  leafpath);
        textures[leafpath]=leafTexture;
      } else
        leafTexture=textures[leafpath];
      if (leafTexture == null) {
        throw StateError('assets/leafclump.png did not load.');
      }
      leafTexture.colorSpace = THREE.SRGBColorSpace;
      final leafWidth = leafTexture.image.width?.toDouble();// ?? 327.0;
      final leafHeight = leafTexture.image.height?.toDouble();// ?? 213.0;
      final leafAspect = leafWidth / leafHeight;

      var foliageMaterial = THREE.SpriteMaterial.fromMap({
        'map': leafTexture,
        'color': 0xffffff,
        'alphaTest': 0.5,
      });

      foliageMaterial?.sizeAttenuation = true;
      foliageMaterial?.map?.wrapT = THREE.RepeatWrapping;
      foliageMaterial?.map?.repeat.y = -1.0;
      final THREE.Material foliagePlaneMaterial;
      if (windspeed > 0.0) {
        // Wind ShaderMaterial — used when windspeed > 0.
        // u_windTime is ticked each frame by Tree.updateWind(delta).
        // V is flipped to match the repeat.y=-1 set on the shared texture.
        // sRGB gamma is applied manually since ShaderMaterial bypasses the
        // renderer's automatic output-encoding step.
        final mat = THREE.ShaderMaterial.fromMap({
          'uniforms': {
            'map':         {'value': leafTexture},
            'u_windTime':  {'value': 0.0},
            'u_windSpeed': {'value': windspeed},
          },
          'vertexShader': '''
            uniform float u_windTime;
            uniform float u_windSpeed;
            varying vec2 vUv;

            void main() {
              vUv = uv;

              // Per-instance phase from world-space XZ so each leaf plane
              // sways slightly out of sync with its neighbours.
              float phase = instanceMatrix[3][0] + instanceMatrix[3][2];

              // Scale sway by normalised local Y — top moves more than bottom.
              float normalizedY = clamp(position.y + 0.5, 0.0, 1.0);
              float power = (u_windSpeed / 5.0) * 0.5;
              float sway  = sin(u_windTime + phase) * power * normalizedY;

              float c = cos(sway);
              float s = sin(sway);
              vec3 pos = position;
              pos.xy = vec2(c * pos.x - s * pos.y,
                            s * pos.x + c * pos.y);

              gl_Position = projectionMatrix
                          * modelViewMatrix
                          * instanceMatrix
                          * vec4(pos, 1.0);
            }
          ''',
          'fragmentShader': '''
            uniform sampler2D map;
            varying vec2 vUv;
            void main() {
              vec2 uv = vec2(vUv.x, 1.0 - vUv.y);
              vec4 c  = texture2D(map, uv);
              if (c.a < 0.5) discard;
              gl_FragColor = vec4(pow(c.rgb, vec3(1.0 / 2.2)), c.a);
            }
          ''',
          'side': THREE.DoubleSide,
          'transparent': false,
        });
        windMaterials.add(mat);
        foliagePlaneMaterial = mat;
      } else {
        // No wind — plain MeshBasicMaterial, not registered in windMaterials.
        foliagePlaneMaterial = THREE.MeshBasicMaterial.fromMap({
          'map': leafTexture,
          'color': 0xffffff,
          'alphaTest': 0.5,
          'transparent': false,
          'side': THREE.DoubleSide,
        });
      }

      leaftextures.add([foliageMaterial, foliagePlaneMaterial, leafAspect, leafscale]);
    }
   /* final leafTexture2;
    if (leafpath2!=null) {
      leafTexture2 = await THREE.TextureLoader().fromAsset(
    'assets/leafclump2.png');
    if (leafTexture2 == null) {
    throw StateError('assets/leafclump.png did not load.');
    }
    }
    leafTexture2.colorSpace = THREE.SRGBColorSpace;*/
 //   const leafSpriteScale = 1.5;
   // const leafSpritesPerTree = 8 * 8;
   // const usePlanes = true;
   // const treeHollowness = 0.3; //0.1;  // 0.0 is totally hollow and 1.0 means not hollow at all - in a sense the width of the non hollow part

    // foliagePlaneMaterial2=null;

    //foliagePlaneMaterial?.map?.wrapT = THREE.RepeatWrapping;
    // foliagePlaneMaterial?.map?.repeat.y = -1.0;
    final rng = math.Random(7);

    var x = 0.0;
    var z =0.0;

    final rotationY = rng.nextDouble() * math.pi * 2;
    final scale = 0.85 + rng.nextDouble() * 0.45;

    final tree = _buildTreeInstance(
      trunkSource: trunkSource,
      //foliageSource: foliageSource,
      trunkMaterial: trunkMaterial,
      //  foliageMaterial: foliageMaterial!,
     // foliagePlaneMaterial: foliagePlaneMaterial!,
    //  foliagePlaneMaterial2: foliagePlaneMaterial2!,
      //leafAspect: leafAspect,
      leaftextures:leaftextures,
     /// leafSpriteScale: leafspritescale,//leafSpriteScale,
      leafSpritesPerTree: leafspritespertree,
      usePlanes: useplanes,
      treeHollowness: treehollowness,//treeHollowness,
      x: x,
      y: 0,
      z: z,
      rotationY: rotationY,
      scale: scale,
      spreadX: spreadx,
    //  spreadYTop: spreadytop ?? spready,
     // spreadYBottom: spreadybottom ?? spready,
      spreadY:spready,
      spreadYTaperTop:spreadytapertop,
      spreadZ: spreadz,
	  randomRoll: randomroll,						 
    );
    return tree;

}

static THREE.Object3D _buildTreeInstance({
  THREE.Mesh? trunkSource,
  // required THREE.Mesh foliageSource,
  THREE.Material? trunkMaterial,
 // THREE.SpriteMaterial? foliageMaterial,
 /// THREE.Material? foliagePlaneMaterial,
 // THREE.Material? foliagePlaneMaterial2,
 // required double leafAspect,
  required List leaftextures,
 // required double leafSpriteScale,
  required int leafSpritesPerTree,
  required bool usePlanes,
  required double treeHollowness,
  required double x,
  required double y,
  required double z,
  required double rotationY,
  required double scale,
  double spreadX=1.0,
  //double spreadYTop=1.0,
 // double spreadYBottom=1.0,
  double spreadY=1.0,
  double spreadZ=1.0,
  double spreadYTaperTop=1.0,
  double randomRoll=0.1,
}) {
  final tree = THREE.Object3D();
  tree.position.setValues(x, y, z);
  tree.rotation.y = rotationY;
  tree.scale.setValues(scale, scale, scale);

  final shadow = false;
  if (trunkSource != null) {
    final trunk = trunkSource.clone() as THREE.Mesh;
    trunk
      ..castShadow = shadow
      ..receiveShadow = shadow
      ..material = trunkMaterial;
    tree.add(trunk);
  }

  // Point 1: One shared PlaneGeometry reused across all sprites and all
  // InstancedMesh instances, instead of allocating a new geometry per sprite.
  final sharedPlane = THREE.PlaneGeometry(1, 1);

  final rng = math.Random((x * 1000).round() ^ (z * 1000).round());

  // Collect each sprite's transform data, grouped by texture index.
  // Each entry holds: [px, py, pz, sx, sy, rx, ry, rz]
  final spriteGroups = <int, List<List<double>>>{};

  for (var i = 0; i < leafSpritesPerTree; i++) {
    // Use the seeded rng for texture selection so the full tree is deterministic.
    final inc = rng.nextInt(leaftextures.length);
    final leafAspect = leaftextures[inc][2] as double;
    final leafSpriteScale = leaftextures[inc][3] as double;

    var offsetX = (rng.nextDouble() * 2.0 - 1.0);
    var offsetY = (rng.nextDouble() * 2.0 - 1.0);
    var offsetZ = (rng.nextDouble() * 2.0 - 1.0);
    if (treeHollowness < 1) {
      // 0.1 means between -1.0 -0.9   to 0.9 to 1.0
      while (offsetX > -1 + treeHollowness && offsetX < 1 - treeHollowness &&
          /* offsetY>-1+treeHollowness&&*/offsetY < 1 - treeHollowness &&
          offsetZ > -1 + treeHollowness && offsetZ < 1 - treeHollowness) {
        offsetX = (rng.nextDouble() * 2.0 - 1.0);
        offsetY = (rng.nextDouble() * 2.0 - 1.0);
        offsetZ = (rng.nextDouble() * 2.0 - 1.0);
      }
    }

    final fct = (offsetY / 2 + 0.5); // turn it to be between 0 and 1
    final spreadfct = 1.0 * (1 - fct) + spreadYTaperTop * fct;

    final spriteScale = leafSpriteScale * (0.7 + rng.nextDouble() * 0.6);
    final flipX = rng.nextBool() ? -1.0 : 1.0;

    final px = offsetX * spreadX * spreadfct;
    final py = offsetY * spreadY + spreadY;
    final pz = offsetZ * spreadZ * spreadfct;

    final sx = spriteScale * leafAspect * (usePlanes ? 1.0 : flipX);
    final sy = usePlanes ? spriteScale : -spriteScale;

    // Plane rotation (only meaningful when usePlanes is true; zeroed otherwise).
    final rx = 0.0;
    final ry = usePlanes
        ? math.atan2(offsetX, offsetZ) + rng.nextDouble() * math.pi * 0.2
        : 0.0;
    //final rz = usePlanes ? rng.nextDouble() * math.pi * 2.0 * 0.1 : 0.0;
    final rz = usePlanes ? rng.nextDouble() * math.pi * 2.0 * randomRoll : 0.0;

    spriteGroups.putIfAbsent(inc, () => []).add([px, py, pz, sx, sy, rx, ry, rz]);
  }

  // Point 3: One InstancedMesh per texture group instead of one Mesh per sprite.
  // All sprites that share the same texture are batched into a single draw call.
  final dummy = THREE.Object3D();
  for (final entry in spriteGroups.entries) {
    final inc     = entry.key;
    final sprites = entry.value;
    // Always use index [1] (MeshBasicMaterial or wind ShaderMaterial).
    // Index [0] is SpriteMaterial which only works on THREE.Sprite — using it
    // on an InstancedMesh causes a renderer cast error at draw time.
    final material = leaftextures[inc][1] as THREE.Material;

    final instancedMesh = THREE.InstancedMesh(sharedPlane, material, sprites.length);
    instancedMesh.castShadow    = shadow;
    instancedMesh.receiveShadow = shadow;
    // InstancedMesh frustum culling uses the base geometry's bounding sphere
    // (a tiny unit plane at the tree root), not the spread of actual instances.
    // This causes the whole mesh to vanish when the camera angles away from the
    // root even though leaf instances are still in view. Disabling the CPU-side
    // frustum check fixes this; the GPU still clips off-screen triangles.
    instancedMesh.frustumCulled = false;

    for (var j = 0; j < sprites.length; j++) {
      final s = sprites[j];
      dummy.position.setValues(s[0], s[1], s[2]); // px, py, pz
      dummy.scale.setValues(s[3], s[4], 1.0);     // sx, sy, 1
      dummy.rotation.set(s[5], s[6], s[7]);        // rx, ry, rz
      dummy.updateMatrix();
      instancedMesh.setMatrixAt(j, dummy.matrix!);
    }
    instancedMesh.instanceMatrix!.needsUpdate = true;

    tree.add(instancedMesh);
  }

  return tree;
}}
