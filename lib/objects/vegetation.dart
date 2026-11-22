// Allows you to draw general purpose vegetation on the terrain cheaply only showing sprite closest to you
// Good for grass and small plants and also can be used to generate static plants eg sprites of trees on a distant hill
// Configurable plant sprites in a single mesh and draw call.

import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:three_js/three_js.dart' as THREE;
import 'package:openworld/openworld.dart' as OPENWORLD;
import '../asset_pack.dart';
import '../updateable.dart';

class PlantSpec {
  // billboard: 0=flat, 1=Y-axis, 2=full, 3=vertical fixed.
  // For flat plants, height is used as ground-plane length.
  // layers: number of cross-planes (1 = single plane, 2+ = multiple rotating planes for volume)
  // widthVariation/heightVariation: fraction of variation (e.g., 0.1 = +/- 10%)
  // planeSize: tiling size (0 = use global planeSize, >= boundary essentially global)
  // pitchVariation: max pitch angle from vertical in radians (for billboard 3)
  // edgeFadeWidth: fade distance near the tile edge in planeSize units - rather than have a plant pop into existence when near planesize instead can fade it in or out
  // exclusionOffset: extra total width/length added to each exclusion square when tested - given an exclusion square how much further from edge eg a cyprus tree needs to be further than a myrle tree  from the road
  // zOffset: vertical offset applied to every plant instance
  // useFootprintExclusion: skip plants whose footprint overlaps exclusion squares
  // excludeSquares: world-space squares [x, z, w, l] that suppress only this plant type
  const PlantSpec({
    required this.spriteAsset,
    required this.count,
    required this.width,
    required this.height,
    this.zOffset = 0.0,
    this.billboard = 1,
    this.flipProbability = 0.5,
    this.layers = 1,
    this.widthVariation = 0.0,
    this.heightVariation = 0.0,
    this.planeSize = 0.0,
    this.pitchVariation = 0.0,
    this.edgeFadeWidth = 0.0,
    this.exclusionOffset = 0.01,
    this.useFootprintExclusion = false,
    this.excludeSquares,
    this.scrolling = true,
  });

  final String spriteAsset;
  final int count;
  final double width;
  final double height;
  final double zOffset;
  final int billboard;
  final double flipProbability;
  final int layers;
  final double widthVariation;
  final double heightVariation;
  final double planeSize;
  final double pitchVariation;
  final double edgeFadeWidth;
  final double exclusionOffset;
  final bool useFootprintExclusion;
  // Per-plant exclusion squares in world coordinates [x, z, width, length].
  // These are tested independently of the global excludeSquares passed to
  // createGrass, and only suppress instances of this specific plant type.
  final List<List<double>>? excludeSquares;
  // If false, this plant type is scattered at fixed positions within the
  // boundary and never wraps/scrolls as the camera moves.  count then means
  // exactly that many instances, always present.
  final bool scrolling;
}

class _PlantRuntime {
  _PlantRuntime(this.spec, this.sprite, this.excludeSquareData);

  final PlantSpec spec;
  final THREE.Texture? sprite;
  // Processed (coordinate-transformed, clamped) per-plant exclusion squares.
  final List<List<double>> excludeSquareData;
}


/// Specifies a secondary texture to blend over the terrain surface within
/// the vegetation boundary.
///
/// The texture is tiled using world-space XZ coordinates so it doesn't stretch
/// regardless of boundary size.  It fades out smoothly at the boundary edges.
///
/// Usage:
///   createGrass(camera, ...,
///     surfaceTexture: SurfaceTextureSpec(
///       asset: 'assets/terrain/stones_leaves.png',
///       blendStrength: 0.6,
///       tilingScale: 12.0,
///       edgeFade: 0.25,
///     ),
///   );
class SurfaceTextureSpec {
  const SurfaceTextureSpec({
    required this.asset,
    this.blendStrength = 0.5,
    this.tilingScale   = 10.0,
    this.edgeFade      = 0.2,
  });

  /// Asset path of the secondary texture (PNG with optional alpha).
  final String asset;

  /// Overall opacity of the overlay in [0, 1].
  final double blendStrength;

  /// How many world metres before the texture repeats.
  final double tilingScale;

  /// Fraction of the boundary half-extent used for the smooth edge fade.
  /// 0.0 = hard cut, 0.25 = fade over the outer 25% of the boundary.
  final double edgeFade;
}

class Vegetation extends Updateable {
  // Terrain points/triangles are now only used on the CPU to bake the
  // terrain height map (see _bakeHeightMap), not sent to the GPU as uniform
  // arrays, so these caps can be generous. Previously 512/1024 as uniform
  // arrays, which needed ~3,800 vertex uniform vectors and failed to link on
  // macOS/iOS (limit 1024) and most Android devices.
  static const int _kMaxTerrainPoints = 8192;
  static const int _kMaxTerrainTriangles = 16384;
  // Default texels per side of the terrain height map texture.
  static const int _kDefaultHeightMapResolution = 256;
  static const int _kMaxExclusionSquares = 96;//32;
  // Total per-plant exclusion squares across all plants combined.
  static const int _kMaxPlantExclusionSquares = 64;
  static const int _kMaxPlants = 10;

  static Map textures={};						 
  // Plant geometry is generated from the provided list.

  static void init() {
    textures = {};
  }

  double _kPlaneSize            = 30.0;
  List<_PlantRuntime> _plants = [];

  double _kSpriteAlphaThreshold = 0.8;

  double _kGrassShadow = 0.5;  // Make the grass darker at the bottom

  double _kMeshScale      = 0.07;
  double _kWindSpeed      = 0.0;
  double _kBoundaryWidth  = 200.0;
  double _kBoundaryLength = 200.0;
  double _kEdgeFalloff    = 20.0;
  bool   _kShowHeightGrid = false;
  int    _kHeightGridDivisions = 20;
  int    _kHeightGridColor = 0xff6a00;
  double _kHeightGridOffset = 0.002;

  late THREE.ShaderMaterial _grassMaterial;
  late THREE.Mesh           _grassMesh;

  late Map<String, dynamic> _iTimeUniform;
  late Map<String, dynamic> _windSpeedUniform;
  final THREE.Vector2       _cameraXZVec = THREE.Vector2(0.0, 0.0);
  late Map<String, dynamic> _cameraXZUniform;
  late Map<String, dynamic> _boundaryUniform;
  late Map<String, dynamic> _meshScaleUniform;
  late Map<String, dynamic> _planeSizeUniform;
  late Map<String, dynamic> _grassShadowUniform;

  late var _camera;

  List<List<double>> _terrainHeights = [];
  List<_TerrainTriangle> _terrainTriangles = [];
  List<List<double>> _exclusionSquareData = [];

  // Baked terrain height map (heights in world units, relative to the
  // vegetation centre) covering the boundary. Row-major, _heightMapRes per side.
  Float64List? _heightMap;
  int _heightMapRes = 0;
  THREE.DataTexture? _heightMapTexture;

  bool _plantOverlapsExclusion(
    double worldX,
    double worldZ,
    double plantRadiusWorld,
    double exclusionOffset,
    List<List<double>> exclusionSquareData,
  ) {
    if (exclusionSquareData.isEmpty) return false;
    final padding = max(0.0, exclusionOffset) * 0.5;
    for (final sq in exclusionSquareData) {
      final dx = (worldX - sq[0]).abs();
      final dz = (worldZ - sq[1]).abs();
      final halfW = sq[2].abs() * 0.5 + padding;
      final halfL = sq[3].abs() * 0.5 + padding;
      if (dx <= halfW + plantRadiusWorld && dz <= halfL + plantRadiusWorld) {
        return true;
      }
    }
    return false;
  }

  bool _usesExclusion(PlantSpec plant) {
    return plant.useFootprintExclusion || plant.exclusionOffset.abs() > 0.000001;
  }

  bool _hasPlantExclusion(PlantSpec plant) {
    return plant.excludeSquares != null && plant.excludeSquares!.isNotEmpty;
  }

  createGrass(camera, {
    grassShadow          = 0.5,
    boundaryWidth        = 200,
    boundaryLength       = 200,
    edgeFalloff          = 20,
    planeSize            = 30,
    layerFadeAngle       = 0.25,
    showHeightGrid       = false,
    int heightMapResolution = _kDefaultHeightMapResolution,
    heightGridDivisions  = 20,
    heightGridColor      = 0xff6a00,
    heightGridOffset     = 0.002,
    int? seed,
    List<List<double>>? excludeSquares,
    List<List<double>>? heightPoints,
    List<PlantSpec> plants = const [],
    worldposx,
    worldposy,
    windSpeed=0.0,
    SurfaceTextureSpec? surfaceTexture,
    THREE.Color? color,
  }) async {
    // So can reuse the old excludeSquares make a copy
    List<List<double>>? useExcludeSquares;
    useExcludeSquares=[];
    if (excludeSquares==null) {

    } else {
      // Is a pain cannot just copy entire array
      for (var square in excludeSquares) {
        useExcludeSquares.add([...square]);
      }
      //useExcludeSquares =
     //     excludeSquares.map((innerList) => List.from(innerList)).toList();
     // ; //[...excludeSquares];  //deepCopy = original.map((item) => Item(item.name, item.id)).toList();;
    }
    if (worldposx!=null&&useExcludeSquares.length>0) {
        for (var i=0; i<useExcludeSquares.length; i++) {
          useExcludeSquares[i][0]=-(worldposx- (useExcludeSquares[i][0]));
          useExcludeSquares[i][1]=  worldposy-useExcludeSquares[i][1];
        //  print("exclude"+excludeSquares[i].toString());
        }
    }
    if (heightPoints==null)
      heightPoints=[];

    // When we build height data directly from mesh faces we also capture the
    // triangle connectivity, so the Delaunay re-triangulation step can be
    // skipped.  null means "no direct triangles available – please triangulate".
    List<_TerrainTriangle>? directTriangles;

    if (heightPoints.length==0&&worldposx!=null) {
      heightPoints=[];
      var localx = worldposx;
      var localz = -worldposy;
      var localy = camera.position.y+100;
      THREE.Intersection intersectiono = OPENWORLD.Space
          .localIntersectSurfaceVector(localx, localy, localz);

     // THREE.Face? face = intersectiono.face;
      //int ind=intersection?.index;
      // int ind=intersection?.

      var mesh = intersectiono.object; //OPENWORLD.Space.mesh.children[0];//ind];
      THREE.BufferGeometry? geom = mesh?.geometry;
      print("mesh veg"+mesh.toString());
      print("mesh geom"+geom.toString());
      THREE.Float32BufferAttribute positions = geom?.getAttribute(
          THREE.Attribute.position);
      THREE.Float32Array pos = positions.array;
      //var poslist = pos.toList();
      /*print('posit inter' + intersectiono!.index.toString() + " " +
          poslist.length.toString() + " " + face!.a.toString() + " " +
          face!.b.toString() + " " + face!.c.toString()); //poslist.toString());
      print("posa" + positions.getX(face!.a).toString() + "," +
          positions.getY(face!.a).toString() + "," +
          positions.getZ(face!.a).toString());
      print("posb" + positions.getX(face!.b).toString() + "," +
          positions.getY(face!.b).toString() + "," +
          positions.getZ(face!.b).toString());
      print("posc" + positions.getX(face!.c).toString() + "," +
          positions.getY(face!.c).toString() + "," +
          positions.getZ(face!.c).toString());*/
      //positionAttribute.getY(aIndex),
      //positionAttribute.getZ(aIndex)
      // print("posx"+pos[face!.a].toString());
      var worldcenterz = OPENWORLD.Space.worldIntersectSurface(
          worldposx, worldposy);
      // Collect terrain faces that overlap the vegetation boundary by iterating
      // the mesh index buffer once — O(face_count) — instead of firing one
      // raycast per integer pixel across the boundary area (~40 k raycasts for
      // a 200×200 boundary).
      final boundLeft   = worldposx - boundaryWidth  / 2;
      final boundRight  = worldposx + boundaryWidth  / 2;
      final boundTop    = worldposy - boundaryLength / 2;
      final boundBottom = worldposy + boundaryLength / 2;

      // Named records: each entry is a (a, b, c) triplet of position-buffer indices.
      final facelist = <({int a, int b, int c})>[];

      // The mesh may be indexed (has an index buffer) or non-indexed (every 3
      // consecutive position-buffer entries form a triangle directly).  Handle
      // both: build a lightweight Iterable of (a, b, c) vertex-index triples
      // without duplicating the overlap-test logic.
      final indexAttr  = geom?.getIndex();
      final vertCount  = positions.count ?? (positions.array.length ~/ 3);
      final faceCount  = indexAttr != null
          ? indexAttr.array.length ~/ 3
          : vertCount ~/ 3;

      for (var f = 0; f < faceCount; f++) {
        final int a, b, c;
        if (indexAttr != null) {
          a = indexAttr.array[f * 3    ].toInt();
          b = indexAttr.array[f * 3 + 1].toInt();
          c = indexAttr.array[f * 3 + 2].toInt();
        } else {
          // Non-indexed geometry: vertices are already unrolled in triples.
          a = f * 3;
          b = f * 3 + 1;
          c = f * 3 + 2;
        }

        // Coordinate convention: world-X = mesh-local X, world-Y = -mesh-local Z
        final ax = positions.getX(a)!.toDouble();
        final az = positions.getZ(a)!.toDouble();
        final bx = positions.getX(b)!.toDouble();
        final bz = positions.getZ(b)!.toDouble();
        final cx = positions.getX(c)!.toDouble();
        final cz = positions.getZ(c)!.toDouble();

        // Negate Z to get world-Y, then compute face AABB for the overlap test.
        final wy_a = -az, wy_b = -bz, wy_c = -cz;
        final faceMinX = ax < bx ? (ax < cx ? ax : cx) : (bx < cx ? bx : cx);
        final faceMaxX = ax > bx ? (ax > cx ? ax : cx) : (bx > cx ? bx : cx);
        final faceMinY = wy_a < wy_b ? (wy_a < wy_c ? wy_a : wy_c) : (wy_b < wy_c ? wy_b : wy_c);
        final faceMaxY = wy_a > wy_b ? (wy_a > wy_c ? wy_a : wy_c) : (wy_b > wy_c ? wy_b : wy_c);

        //if (!(faceMinX < boundLeft  && faceMaxX > boundRight &&
        //    faceMinY > boundTop   && faceMaxY > boundBottom)) {
        if (faceMaxX >= boundLeft  && faceMinX <= boundRight &&
            faceMaxY >= boundTop   && faceMinY <= boundBottom) {
          facelist.add((a: a, b: b, c: c));
        }
      }
      print("facelist count"+facelist.length.toString());

      // Build height-point list and terrain triangles in a single pass over
      // the collected faces.  A map from the mesh's buffer index to our local
      // heightPoints index lets us deduplicate shared vertices in O(1) and
      // reconstruct the exact face triangles without any re-triangulation.
      final bufferIndexToHeightIndex = <int, int>{};
      directTriangles = [];

      for (var face in facelist) {
        final faceIndices = [face.a, face.b, face.c];
        final localIndices = <int>[];
        var faceValid = true;

        for (final bufIdx in faceIndices) {
          if (!bufferIndexToHeightIndex.containsKey(bufIdx)) {
            // Respect the per-instance cap early so triangle indices stay valid.
            if (heightPoints.length >= _kMaxTerrainPoints) {
              faceValid = false;
              break;
            }
            final xa = positions.getX(bufIdx)!.toDouble();
            final ya = positions.getY(bufIdx)!.toDouble();
            final za = positions.getZ(bufIdx)!.toDouble();
            // Coordinate convention: world-X = xa, world-Y = -za, height = ya
            final x = xa - worldposx;
            final y = worldposy - (-za);
            final z = ya - worldcenterz;
            bufferIndexToHeightIndex[bufIdx] = heightPoints.length;
            heightPoints.add([x, y, z]);
          }
          localIndices.add(bufferIndexToHeightIndex[bufIdx]!);
        }

        if (faceValid && directTriangles.length < _kMaxTerrainTriangles) {
          directTriangles.add(
            _TerrainTriangle(localIndices[0], localIndices[1], localIndices[2]),
          );
        }
      }

      /*for (var j = -1; j < boundaryLength + 1; j++) {
        var prevz = -9999.0;
        for (var i = -1; i < boundaryWidth + 1; i++) {
          if ((i % 4 == 0 &&
              j % 4 == 0)) { //||(i - boundarywidth2 / 2).abs()<2) {
            var worldx = worldposx - boundaryWidth / 2 + i;
            //    var worldy=worldposy-boundarylength2/2+j;
            var worldy = worldposy + boundaryLength / 2 - j;
            var worldz = OPENWORLD.Space.worldIntersectSurface(worldx, worldy);
            var x = i - boundaryWidth / 2;
            var y = j - boundaryLength / 2;
            var z = worldz - worldcenterz;
            //print('posss '+x.toString()+" "+y.toString()+' '+z.toString()+' w'+worldx.toString()+" "+worldy.toString()+" "+worldz.toString());//+" "+worldcenterz.toString());
            print(
                '[' + x.toString() + ", " + y.toString() + ', ' + z.toString() +
                    ']'); //+' '+(i - boundarywidth2 / 2).abs().toString());
            if (prevz == -9999.0 || prevz != z)
              heightPoints.add([x.toDouble(), y.toDouble(), z.toDouble()]);
           // if (prevz == z)
           //   print("xy" + x.toString() + " " + y.toString());
            prevz = z;
          }
        }
      }*/
    }
    print("height points"+heightPoints.length.toString());

    _camera = camera;
    _kWindSpeed=windSpeed;
    _kGrassShadow         = grassShadow.toDouble();
    _kBoundaryWidth       = boundaryWidth.toDouble();
    _kBoundaryLength      = boundaryLength.toDouble();
    _kEdgeFalloff         = edgeFalloff.toDouble();
    _kPlaneSize           = planeSize.toDouble();
    _kShowHeightGrid      = showHeightGrid == true;
    _kHeightGridDivisions = max(1, heightGridDivisions is int
        ? heightGridDivisions
        : (heightGridDivisions as num).toInt());
    _kHeightGridColor     = heightGridColor is int
        ? heightGridColor
        : (heightGridColor as num).toInt();
    _kHeightGridOffset    = heightGridOffset.toDouble();
    final exclusionSquareData = useExcludeSquares
        .take(_kMaxExclusionSquares)
        .where((sq) => sq.length >= 3)
        .map((sq) {
          final width = sq[2].toDouble();
          final length = (sq.length >= 4 ? sq[3] : sq[2]).toDouble();
          return [sq[0].toDouble(), sq[1].toDouble(), width, length];
        })
        .toList();
    _exclusionSquareData = exclusionSquareData;
    _terrainHeights       = heightPoints
        .take(_kMaxTerrainPoints)
        .map((pt) => [pt[0].toDouble(), pt[1].toDouble(), pt[2].toDouble()])
        .toList();
    // When height data came from the mesh we already have the correct triangle
    // connectivity; skip the Delaunay re-triangulation in that case.
    _terrainTriangles     = directTriangles ?? _buildTerrainTriangles();

    final defaultPlants = plants;/* plants.isNotEmpty
        ? plants
        : const [
            PlantSpec(
              spriteAsset: 'assets/shaders/grass.png',
              count: 10000,
              width: 0.024,
              height: 0.24,
              billboard: 1,
              flipProbability: 0.5,
            ),
          ];*/
    // Build _PlantRuntime list, processing each plant's per-plant exclusion
    // squares into local coordinates immediately so the flat-array packing below
    // and the CPU scatter test in _generateField both see the correct data.
    _plants = defaultPlants.take(_kMaxPlants).map((spec) => _PlantRuntime(
      spec,
      null,
      _processPlantExcludeSquares(spec, worldposx, worldposy),
    )).toList();

    // Pack all per-plant exclusion squares into one flat array.
    // Record the start index and count for each plant so the shader can find
    // its slice without a separate array per plant.
    final plantExcludeSquaresFlat = <THREE.Vector4>[];
    final plantExcludeStarts = <int>[];
    final plantExcludeCounts = <int>[];
    for (final runtime in _plants) {
      plantExcludeStarts.add(plantExcludeSquaresFlat.length);
      final squares = runtime.excludeSquareData
          .take(_kMaxPlantExclusionSquares - plantExcludeSquaresFlat.length)
          .toList();
      plantExcludeCounts.add(squares.length);
      for (final sq in squares) {
        plantExcludeSquaresFlat.add(THREE.Vector4(sq[0], sq[1], sq[2], sq[3]));
      }
    }
    // Pad to fixed size so the uniform array length is always known at compile time.
    while (plantExcludeSquaresFlat.length < _kMaxPlantExclusionSquares) {
      plantExcludeSquaresFlat.add(THREE.Vector4(0.0, 0.0, 0.0, 0.0));
    }
    // Pad start/count lists to _kMaxPlants entries.
    while (plantExcludeStarts.length < _kMaxPlants) {
      plantExcludeStarts.add(0);
      plantExcludeCounts.add(0);
    }

        final exclusionSquareUniforms = List<THREE.Vector4>.generate(
      _kMaxExclusionSquares,
      (index) {
        if (index < exclusionSquareData.length) {
          final sq = exclusionSquareData[index];
          return THREE.Vector4(sq[0], sq[1], sq[2], sq[3]);
        }
        return THREE.Vector4(0.0, 0.0, 0.0, 0.0);
      },
    );

    final hasEdgeFadePlants = _plants.any((p) => p.spec.edgeFadeWidth > 0.0);

    // Bake the terrain under the boundary into a height map texture that the
    // vertex shader samples, instead of uploading points/triangles as uniforms.
    _bakeHeightMap(heightMapResolution);
  //  final loader = THREE.TextureLoader();
    final plantSprites = <THREE.Texture?>[];
    for (final plant in _plants) {
	      var spriteTexture;
      if (plant.spec.spriteAsset.isNotEmpty) {
        if (!textures.containsKey(plant.spec.spriteAsset)) {
          spriteTexture =await  AssetPack.loadTexture(plant.spec.spriteAsset);// await loader.fromAsset(plant.spec.spriteAsset);
          textures[plant.spec.spriteAsset]=spriteTexture;
        } else
          spriteTexture=textures[plant.spec.spriteAsset];
      } else
        spriteTexture=null;
      plantSprites.add(spriteTexture);//plant.spec.spriteAsset.isNotEmpty
       //   ? await loader.fromAsset(plant.spec.spriteAsset)
        //  : null);
    /*  plantSprites.add(plant.spec.spriteAsset.isNotEmpty
          ? await loader.fromAsset(plant.spec.spriteAsset)
          : null);*/
    }
    _plants = [
      for (int i = 0; i < _plants.length; i++)
        _PlantRuntime(_plants[i].spec, plantSprites[i], _plants[i].excludeSquareData),
    ];

    final vertSrc = await rootBundle.loadString('assets/shaders/vegetation.vert.glsl');
    final fragSrc = await rootBundle.loadString('assets/shaders/vegetation.frag.glsl');

    final uniforms = <String, dynamic>{
      'spriteAlphaThreshold': {'value': _kSpriteAlphaThreshold},
      // Web loads textures the other way up, so flip the sprites there
      'spriteFlipY': {'value': kIsWeb ? 1.0 : 0.0},
      'plantCount': {'value': _plants.length.toDouble()},
      'terrainHeightMap': {'value': _heightMapTexture},
      'heightMapHalf': {'value': THREE.Vector2(
          max(_kBoundaryWidth / 2.0, 0.0001), max(_kBoundaryLength / 2.0, 0.0001))},
      'heightMapRes': {'value': max(_heightMapRes, 2).toDouble()},
      'heightMapValid': {'value': _heightMapTexture != null ? 1.0 : 0.0},
      'excludeSquareCount': {'value': exclusionSquareData.length.toDouble()},
      'excludeSquares': {'value': exclusionSquareUniforms},
      'plantExcludeSquares': {'value': plantExcludeSquaresFlat},
      'iTime': {'value': 0.0},
      'windSpeed': {'value': _kWindSpeed},
      'cameraXZ': {'value': THREE.Vector2(0.0, 0.0)},
      'boundaryHalf': {'value': THREE.Vector2(
          _kBoundaryWidth / 2.0, _kBoundaryLength / 2.0)},
      'edgeFalloff': {'value': _kEdgeFalloff},
      'meshScale': {'value': _kMeshScale},
      'planeSize': {'value': _kPlaneSize},
      'layerFadeAngle': {'value': layerFadeAngle.toDouble()},
      'grassShadow': {'value': _kGrassShadow},
      // Standard Three.js fog uniform names - WebGLRenderer auto-populates
      // these from scene.fog every frame for any material with fog=true,
      // regardless of whether it's a built-in or fully custom
      // ShaderMaterial. Initial values here are just placeholders; the
      // renderer overwrites them before the first frame that uses them.
      'fogColor': {'value': THREE.Color.fromHex32(0xcccccc)},
      'fogNear': {'value': 1.0},
      'fogFar': {'value': 100.0},
      // Multiplied against the sampled sprite color, same role as
      // InstancedBillboards' material.color tint - defaults to white (no
      // change) unless a [color] was passed to createGrass().
      'ambientColor': {'value': color ?? THREE.Color.fromHex32(0xffffff)},
    };
    for (int i = 0; i < _kMaxPlants; i++) {
      final sprite = i < _plants.length ? _plants[i].sprite : null;
      final plantPlaneSize = i < _plants.length && _plants[i].spec.planeSize > 0.0
          ? _plants[i].spec.planeSize
          : _kPlaneSize;
      final plantEdgeFadeWidth = i < _plants.length
          ? _plants[i].spec.edgeFadeWidth
          : 0.0;
      final plantExclusionOffset = i < _plants.length
          ? _plants[i].spec.exclusionOffset
          : 0.0;
      final plantUseExclusion = i < _plants.length && _usesExclusion(_plants[i].spec);
      uniforms['plantSprite$i'] = {'value': sprite};
      uniforms['plantUseSprite$i'] = {'value': sprite != null ? 1.0 : 0.0};
      uniforms['plantBillboard$i'] = {
        'value': i < _plants.length ? _plants[i].spec.billboard.toDouble() : 0.0,
      };
      uniforms['plantPlaneSize$i'] = {'value': plantPlaneSize};
      uniforms['plantEdgeFadeWidth$i'] = {'value': plantEdgeFadeWidth};
      uniforms['plantUseFootprintExclusion$i'] = {
        'value': plantUseExclusion ? 1.0 : 0.0,
      };
      uniforms['plantExclusionOffset\$i'] = {'value': plantExclusionOffset};
      uniforms['plantScrolling$i'] = {'value': (i < _plants.length && _plants[i].spec.scrolling) ? 1.0 : 0.0};
      uniforms['plantExcludeStart$i'] = {'value': (i < plantExcludeStarts.length ? plantExcludeStarts[i] : 0).toDouble()};
      uniforms['plantExcludeCount$i'] = {'value': (i < plantExcludeCounts.length ? plantExcludeCounts[i] : 0).toDouble()};
    }

    _grassMaterial = THREE.ShaderMaterial.fromMap({
      'uniforms': uniforms,
      'vertexShader':   vertSrc,
      'fragmentShader': fragSrc,
      'side': THREE.DoubleSide,
    });
    _grassMaterial.vertexColors = false;
    _grassMaterial.transparent = false;
    _grassMaterial.depthWrite = true;
    _grassMaterial.fog = true;

    _iTimeUniform      = _grassMaterial.uniforms['iTime']!;
    _windSpeedUniform  = _grassMaterial.uniforms['windSpeed']!;
    _cameraXZUniform   = _grassMaterial.uniforms['cameraXZ']!;
    _cameraXZUniform['value'] = _cameraXZVec;
    _boundaryUniform       = _grassMaterial.uniforms['boundaryHalf']!;
    _meshScaleUniform      = _grassMaterial.uniforms['meshScale']!;
    _planeSizeUniform      = _grassMaterial.uniforms['planeSize']!;
    _grassShadowUniform = _grassMaterial.uniforms['grassShadow']!;

    final mesh = _generateField(seed: seed);

    if (surfaceTexture != null) {
      final overlay = await _buildSurfaceOverlay(surfaceTexture);
      if (overlay != null) {
        mesh.add(overlay);
      }
    }

    return mesh;
  }

  // ── Update (called every frame by the game) ────────────────────────────────

  @override
  update(frameTime, elapsedTime) {
    _iTimeUniform['value'] = elapsedTime * 1000.0;
    _cameraXZVec.x = _camera.position.x - _grassMesh.position.x;
    _cameraXZVec.y = _camera.position.z - _grassMesh.position.z;
  }

  // ── Geometry generation ────────────────────────────────────────────────────


  /// Builds a transparent overlay mesh that tiles [spec.asset] over the
  /// terrain surface within the boundary.  The mesh is constructed directly
  /// from [_terrainTriangles] / [_terrainHeights] — no extra raycasts needed.
  ///
  /// Returns null if there is no terrain height data (e.g. flat terrain with
  /// no mesh intersection).
  Future<THREE.Mesh?> _buildSurfaceOverlay(SurfaceTextureSpec spec) async {
    if (_terrainTriangles.isEmpty || _terrainHeights.isEmpty) return null;

    // ── Vertices ────────────────────────────────────────────────────────────
    // _terrainHeights entries are [worldRelX, worldRelZ, heightWorld] in world
    // metres.  The overlay mesh is a child of _grassMesh which is already
    // scaled by _kMeshScale, so we convert to local units by dividing.
    final vertCount = _terrainHeights.length;
    final positions = THREE.Float32Array(vertCount * 3);

    for (int i = 0; i < vertCount; i++) {
      final pt = _terrainHeights[i];
      // pt[0] = worldRelX, pt[1] = worldRelZ, pt[2] = height (all world metres)
      positions[i * 3 + 0] = pt[0] / _kMeshScale;  // local X
      positions[i * 3 + 1] = pt[2] / _kMeshScale;  // local Y (up)
      positions[i * 3 + 2] = pt[1] / _kMeshScale;  // local Z
    }

    // ── Indices ─────────────────────────────────────────────────────────────
    final triCount = _terrainTriangles.length;
    final indices  = THREE.Uint32Array(triCount * 3);
    for (int i = 0; i < triCount; i++) {
      final tri = _terrainTriangles[i];
      indices[i * 3 + 0] = tri.a;
      indices[i * 3 + 1] = tri.b;
      indices[i * 3 + 2] = tri.c;
    }

    final geom = THREE.BufferGeometry();
    geom.setAttributeFromString(
        'position', THREE.Float32BufferAttribute(positions, 3));
    geom.setIndex(THREE.Uint32BufferAttribute(indices, 1));

    // ── Texture ─────────────────────────────────────────────────────────────
    //final loader  = THREE.TextureLoader();
    final texture = textures.containsKey(spec.asset)
        ? textures[spec.asset] as THREE.Texture
        : await  AssetPack.loadTexture(spec.asset);//await loader.fromAsset(spec.asset);
    textures[spec.asset] = texture;
    texture?.wrapS = THREE.RepeatWrapping;
    texture?.wrapT = THREE.RepeatWrapping;

    // ── Shaders ─────────────────────────────────────────────────────────────
    final vertSrc = await rootBundle
        .loadString('assets/shaders/surface_overlay.vert.glsl');
    final fragSrc = await rootBundle
        .loadString('assets/shaders/surface_overlay.frag.glsl');

    // UV scaling: worldXZ (metres) / tilingScale → UV.
    // In the shader position.xz is in local units, so:
    //   UV = position.xz * meshScale / tilingScale
    //      = position.xz * uvScale
    final uvScale = _kMeshScale / spec.tilingScale;

    // Boundary half-extents in local units (shader uses position.xz directly).
    final bndHalfLocal = THREE.Vector2(
      _kBoundaryWidth  / 2.0 / _kMeshScale,
      _kBoundaryLength / 2.0 / _kMeshScale,
    );

    // depthNudge lifts the overlay above the terrain surface in local units.
    // 0.02 local units = ~1.4 mm world space — invisible but clears depth
    // precision threshold at all camera distances, preventing Z-fighting flicker.
    const depthNudge = 0.02;

    final overlayUniforms = <String, dynamic>{
      'surfaceTexture': {'value': texture},
      'blendStrength':  {'value': spec.blendStrength},
      'uvScale':        {'value': uvScale},
      'boundaryHalf':   {'value': bndHalfLocal},
      'edgeFade':       {'value': spec.edgeFade},
      'depthNudge':     {'value': depthNudge},
      'fogColor': {'value': THREE.Color(0xcccccc)},
      'fogNear': {'value': 1.0},
      'fogFar': {'value': 100.0},
    };

    final material = THREE.ShaderMaterial.fromMap({
      'uniforms':       overlayUniforms,
      'vertexShader':   vertSrc,
      'fragmentShader': fragSrc,
      'side':           THREE.DoubleSide,
    });
    material.fog = true;
    material.transparent  = true;
    // depthWrite off avoids Z-fighting with the terrain without needing
    // polygonOffset (which isn't universally supported in Flutter three_js).
    material.depthWrite   = false;

    final overlay = THREE.Mesh(geom, material);
    overlay.frustumCulled = false;
    // The parent _grassMesh already applies _kMeshScale, so no scale needed here.
    return overlay;
  }

  _generateField({int? seed}) {
    final rand = Random();
    final positionRand = seed == null ? Random() : Random(seed);

    final totalVerts = _plants.fold<int>(0, (sum, plant) => sum + plant.spec.count * plant.spec.layers * 4);
    final totalIndices = _plants.fold<int>(0, (sum, plant) => sum + plant.spec.count * plant.spec.layers * 6);

    final positions   = THREE.Float32Array(totalVerts * 3);
    final uvs         = THREE.Float32Array(totalVerts * 2);
    final types       = THREE.Float32Array(totalVerts);
    final corners     = THREE.Float32Array(totalVerts * 2);
    final quadHalfSizes = THREE.Float32Array(totalVerts * 2);
    final quadYaws    = THREE.Float32Array(totalVerts * 2);
    final flipHs      = THREE.Float32Array(totalVerts);
    final quadPitches = THREE.Float32Array(totalVerts);
    final indices     = THREE.Uint32Array(totalIndices);

    int posIdx = 0, uvIdx = 0, typeIdx = 0, flipIdx = 0, pitchIdx = 0;
    int cIdx = 0, qhsIdx = 0, qyIdx = 0;
    int idxIdx = 0, vertBase = 0;

    for (int plantIndex = 0; plantIndex < _plants.length; plantIndex++) {
      final plant = _plants[plantIndex].spec;
      final plantGenSize = plant.planeSize > 0.0 ? plant.planeSize : _kPlaneSize;
      for (int i = 0; i < plant.count; i++) {
        // Static plants scatter across the full boundary so all count instances
        // are always present.  Scrolling plants scatter within planeSize and
        // tile via the mod() wrap in the vertex shader.
        final scatterHalfW = plant.scrolling ? plantGenSize * 0.5 : _kBoundaryWidth  * 0.5 / _kMeshScale;
        final scatterHalfL = plant.scrolling ? plantGenSize * 0.5 : _kBoundaryLength * 0.5 / _kMeshScale;
        final x = (positionRand.nextDouble() - 0.5) * 2.0 * scatterHalfW;
        final z = (positionRand.nextDouble() - 0.5) * 2.0 * scatterHalfL;
        final y = plant.zOffset;
        final widthMult = 1.0 + (rand.nextDouble() * 2.0 - 1.0) * plant.widthVariation;
        final plantHeightMult = 1.0 + (rand.nextDouble() * 2.0 - 1.0) * plant.heightVariation;
        final plantRadiusWorld = max(
          plant.width * widthMult,
          plant.height * plantHeightMult,
        ) * 0.5 * _kMeshScale;
      //  print('Plant: x=${x * _kMeshScale}, z=${z * _kMeshScale}');
       // print('Exclusion squares: $_exclusionSquareData');
        if (_usesExclusion(plant) &&
            _plantOverlapsExclusion(
                x * _kMeshScale,
                z * _kMeshScale,
                plantRadiusWorld,
                plant.exclusionOffset,
                _exclusionSquareData)) {
          continue;
        }
        final plantRuntime = _plants[plantIndex];
        if (_hasPlantExclusion(plant) &&
            _plantOverlapsExclusion(
                x * _kMeshScale,
                z * _kMeshScale,
                plantRadiusWorld,
                0.0,
                plantRuntime.excludeSquareData)) {
          continue;
        }

        for (int layer = 0; layer < plant.layers; layer++) {
          final layerAngle = plant.layers > 1 ? (layer * pi / plant.layers) : 0.0;
          _writePlant(
            plantIndex: plantIndex,
            cx: x,
            cy: y,
            cz: z,
            vBase: vertBase,
            uvX: x,
            uvY: z,
            rand: rand,
            plant: plant,
            widthMult: widthMult,
            heightMult: plantHeightMult,
            layerAngle: layerAngle,
            positions: positions,
            posIdx: posIdx,
            uvs: uvs,
            uvIdx: uvIdx,
            corners: corners,
            cIdx: cIdx,
            quadHalfSizes: quadHalfSizes,
            qhsIdx: qhsIdx,
            quadYaws: quadYaws,
            qyIdx: qyIdx,
            types: types,
            typeIdx: typeIdx,
            flipHs: flipHs,
            flipIdx: flipIdx,
            quadPitches: quadPitches,
            pitchIdx: pitchIdx,
            indices: indices,
            idxIdx: idxIdx,
          );
          posIdx += 12;
          uvIdx += 8;
          cIdx += 8;
          qhsIdx += 8;
          qyIdx += 8;
          typeIdx += 4;
          flipIdx += 4;
          pitchIdx += 4;
          idxIdx += 6;
          vertBase += 4;
        }
      }
    }

    final geom = THREE.BufferGeometry();
    geom.setAttributeFromString('position',    THREE.Float32BufferAttribute(positions,     3));
    geom.setAttributeFromString('uv',          THREE.Float32BufferAttribute(uvs,           2));
    geom.setAttributeFromString('type',        THREE.Float32BufferAttribute(types,         1));
    geom.setAttributeFromString('corner',      THREE.Float32BufferAttribute(corners,       2));
    geom.setAttributeFromString('quadHalfSize',THREE.Float32BufferAttribute(quadHalfSizes, 2));
    geom.setAttributeFromString('quadYaw',     THREE.Float32BufferAttribute(quadYaws,      2));
    geom.setAttributeFromString('flipH',       THREE.Float32BufferAttribute(flipHs,        1));
    geom.setAttributeFromString('quadPitch',   THREE.Float32BufferAttribute(quadPitches,    1));
    geom.setIndex(THREE.Uint32BufferAttribute(indices, 1));

    _grassMesh = THREE.Mesh(geom, _grassMaterial);
    _grassMesh.frustumCulled = false;
    _grassMesh.scale.setValues(_kMeshScale, _kMeshScale, _kMeshScale);

    final heightGrid = _buildHeightGrid();
    if (heightGrid != null) {
      _grassMesh.add(heightGrid);
    }

    return _grassMesh;
  }

  THREE.LineSegments? _buildHeightGrid() {
    if (!_kShowHeightGrid) return null;

    final divisions = max(1, _kHeightGridDivisions);
    final halfWidth = _kBoundaryWidth / 2.0;
    final halfLength = _kBoundaryLength / 2.0;
    final stepX = _kBoundaryWidth / divisions;
    final stepZ = _kBoundaryLength / divisions;
    final segmentCount = (divisions + 1) * divisions * 2;
    final positions = THREE.Float32Array(segmentCount * 2 * 3);

    int posIdx = 0;

    void writePoint(double worldX, double worldY, double worldZ) {
      positions[posIdx++] = worldX / _kMeshScale;
      positions[posIdx++] = worldY / _kMeshScale;
      positions[posIdx++] = worldZ / _kMeshScale;
    }

    void writeSegment(double x1, double z1, double x2, double z2) {
      final y1 = _sampleTerrainHeightWorld(x1, z1) + _kHeightGridOffset;
      final y2 = _sampleTerrainHeightWorld(x2, z2) + _kHeightGridOffset;
      writePoint(x1, y1, z1);
      writePoint(x2, y2, z2);
    }

    for (int ix = 0; ix <= divisions; ix++) {
      final x = -halfWidth + ix * stepX;
      for (int iz = 0; iz < divisions; iz++) {
        final z1 = -halfLength + iz * stepZ;
        final z2 = z1 + stepZ;
        writeSegment(x, z1, x, z2);
      }
    }

    for (int iz = 0; iz <= divisions; iz++) {
      final z = -halfLength + iz * stepZ;
      for (int ix = 0; ix < divisions; ix++) {
        final x1 = -halfWidth + ix * stepX;
        final x2 = x1 + stepX;
        writeSegment(x1, z, x2, z);
      }
    }

    final geom = THREE.BufferGeometry();
    geom.setAttributeFromString('position', THREE.Float32BufferAttribute(positions, 3));

    final material = THREE.LineBasicMaterial.fromMap({
      'color': _kHeightGridColor,
      'transparent': true,
      'opacity': 0.85,
    });

    final grid = THREE.LineSegments(geom, material);
    grid.frustumCulled = false;
    return grid;
  }

  void _writePlant({
    required int plantIndex,
    required PlantSpec plant,
    required double cx,
    required double cy,
    required double cz,
    required int vBase,
    required double uvX,
    required double uvY,
    required Random rand,
    required double widthMult,
    required double layerAngle,
    required double heightMult,
    required THREE.Float32Array positions,
    required int posIdx,
    required THREE.Float32Array uvs,
    required int uvIdx,
    required THREE.Float32Array corners,
    required int cIdx,
    required THREE.Float32Array quadHalfSizes,
    required int qhsIdx,
    required THREE.Float32Array quadYaws,
    required int qyIdx,
    required THREE.Float32Array types,
    required int typeIdx,
    required THREE.Float32Array flipHs,
    required int flipIdx,
    required THREE.Float32Array quadPitches,
    required int pitchIdx,
    required THREE.Uint32Array indices,
    required int idxIdx,
  }) {
    final flipVal = rand.nextDouble() < plant.flipProbability ? 1.0 : 0.0;
    final billboard = plant.billboard;

    final pitchVal = billboard == 3 && plant.pitchVariation > 0.0
        ? (rand.nextDouble() * 2.0 - 1.0) * plant.pitchVariation
        : 0.0;

    for (int v = 0; v < 4; v++) {
      positions[posIdx + v * 3 + 0] = cx;
      positions[posIdx + v * 3 + 1] = cy;
      positions[posIdx + v * 3 + 2] = cz;
      uvs[uvIdx + v * 2 + 0] = uvX;
      uvs[uvIdx + v * 2 + 1] = uvY;
    }

    double halfSizeX;
    double halfSizeY;
    double yawX = 0.0;
    double yawZ = 0.0;

    if (billboard == 0) {
      final yaw = rand.nextDouble() * pi * 2.0;
      yawX = sin(yaw);
      yawZ = -cos(yaw);
      halfSizeX = plant.height * widthMult / 2.0;
      halfSizeY = plant.width * heightMult / 2.0;
    } else if (billboard == 3) {
      final yaw = plant.layers > 1 ? layerAngle : rand.nextDouble() * pi * 2.0;
      yawX = sin(yaw);
      yawZ = -cos(yaw);
      halfSizeX = plant.width * widthMult / 2.0;
      halfSizeY = plant.height * heightMult;
    } else {
      halfSizeX = plant.width * widthMult / 2.0;
      halfSizeY = plant.height * heightMult;
    }

    _writeQuadShared(
      vBase: vBase,
      halfSizeX: halfSizeX,
      halfSizeY: halfSizeY,
      yawX: yawX,
      yawZ: yawZ,
      typeVal: plantIndex.toDouble(),
      flipVal: flipVal,
      pitchVal: pitchVal,
      corners: corners,
      cIdx: cIdx,
      quadHalfSizes: quadHalfSizes,
      qhsIdx: qhsIdx,
      quadYaws: quadYaws,
      qyIdx: qyIdx,
      types: types,
      typeIdx: typeIdx,
      flipHs: flipHs,
      flipIdx: flipIdx,
      quadPitches: quadPitches,
      pitchIdx: pitchIdx,
      indices: indices,
      idxIdx: idxIdx,
    );
  }

  void _writeQuadShared({
    required int vBase,
    required double halfSizeX,
    required double halfSizeY,
    required double yawX,
    required double yawZ,
    required double typeVal,
    required double flipVal,
    required double pitchVal,
    required THREE.Float32Array corners,
    required int cIdx,
    required THREE.Float32Array quadHalfSizes,
    required int qhsIdx,
    required THREE.Float32Array quadYaws,
    required int qyIdx,
    required THREE.Float32Array types,
    required int typeIdx,
    required THREE.Float32Array flipHs,
    required int flipIdx,
    required THREE.Float32Array quadPitches,
    required int pitchIdx,
    required THREE.Uint32Array indices,
    required int idxIdx,
  }) {
    corners[cIdx + 0] = 0.0; corners[cIdx + 1] = 0.0;
    corners[cIdx + 2] = 1.0; corners[cIdx + 3] = 0.0;
    corners[cIdx + 4] = 1.0; corners[cIdx + 5] = 1.0;
    corners[cIdx + 6] = 0.0; corners[cIdx + 7] = 1.0;

    for (int v = 0; v < 4; v++) {
      quadHalfSizes[qhsIdx + v * 2 + 0] = halfSizeX;
      quadHalfSizes[qhsIdx + v * 2 + 1] = halfSizeY;
      quadYaws[qyIdx + v * 2 + 0] = yawX;
      quadYaws[qyIdx + v * 2 + 1] = yawZ;
      types[typeIdx + v] = typeVal;
      flipHs[flipIdx + v] = flipVal;
      quadPitches[pitchIdx + v] = pitchVal;
    }

    final o = vBase;
    indices[idxIdx + 0] = o; indices[idxIdx + 1] = o + 1; indices[idxIdx + 2] = o + 2;
    indices[idxIdx + 3] = o; indices[idxIdx + 4] = o + 2; indices[idxIdx + 5] = o + 3;
  }

  double _sampleTerrainHeightWorld(double worldX, double worldZ) {
    if (_heightMap != null) return _sampleHeightMapWorld(worldX, worldZ);
    return _sampleTerrainHeightExact(worldX, worldZ);
  }

  /// Exact height from the terrain triangles (IDW fallback outside them).
  double _sampleTerrainHeightExact(double worldX, double worldZ) {
    if (_terrainHeights.isEmpty) return 0.0;
    if (_terrainHeights.length == 1) return _terrainHeights[0][2];

    final linearHeight = _sampleTriangulatedHeightWorld(worldX, worldZ);
    if (linearHeight != null) return linearHeight;

    return _sampleHeightIdwWorld(worldX, worldZ);
  }

  // ── Terrain height map ─────────────────────────────────────────────────────
  //
  // Texel (i, j) holds the terrain height at
  //   x = -halfW + i * (2*halfW / (res-1)),  z = -halfL + j * (2*halfL / (res-1))
  // in the same vegetation-centred world coordinates as _terrainHeights, so
  // the corners of the map sit exactly on the boundary corners. The vertex
  // shader does the same bilinear lookup as _sampleHeightMapWorld below.

  void _bakeHeightMap(int resolution) {
    _heightMap = null;
    _heightMapTexture = null;
    _heightMapRes = 0;
    if (_terrainHeights.isEmpty) return; // flat: shader uses height 0

    final int res = resolution.clamp(2, 2048).toInt();
    final halfW = max(_kBoundaryWidth / 2.0, 0.0001);
    final halfL = max(_kBoundaryLength / 2.0, 0.0001);
    final cellX = 2.0 * halfW / (res - 1);
    final cellZ = 2.0 * halfL / (res - 1);

    final heights = Float64List(res * res);
    final filled = Uint8List(res * res);
    const epsilon = 0.000001;

    // Rasterise each triangle onto the grid points inside its bounding box.
    // First triangle to cover a point wins, like the old shader loop.
    for (final tri in _terrainTriangles) {
      final a = _terrainHeights[tri.a];
      final b = _terrainHeights[tri.b];
      final c = _terrainHeights[tri.c];
      final ax = a[0], az = a[1];
      final bx = b[0], bz = b[1];
      final cx = c[0], cz = c[1];
      final denom = ((bz - cz) * (ax - cx)) + ((cx - bx) * (az - cz));
      if (denom.abs() < epsilon) continue;

      final i0 = max(0, ((min(ax, min(bx, cx)) + halfW) / cellX).ceil());
      final i1 = min(res - 1, ((max(ax, max(bx, cx)) + halfW) / cellX).floor());
      final j0 = max(0, ((min(az, min(bz, cz)) + halfL) / cellZ).ceil());
      final j1 = min(res - 1, ((max(az, max(bz, cz)) + halfL) / cellZ).floor());

      for (int j = j0; j <= j1; j++) {
        final z = -halfL + j * cellZ;
        for (int i = i0; i <= i1; i++) {
          final k = j * res + i;
          if (filled[k] != 0) continue;
          final x = -halfW + i * cellX;
          final wA = ((bz - cz) * (x - cx) + (cx - bx) * (z - cz)) / denom;
          final wB = ((cz - az) * (x - cx) + (ax - cx) * (z - cz)) / denom;
          final wC = 1.0 - wA - wB;
          if (wA >= -epsilon && wB >= -epsilon && wC >= -epsilon) {
            heights[k] = a[2] * wA + b[2] * wB + c[2] * wC;
            filled[k] = 1;
          }
        }
      }
    }

    // Grid points no triangle covers (e.g. boundary runs past the terrain
    // mesh): copy the height of the nearest covered point, spreading outwards
    // one ring at a time - O(res*res). Only if there are no usable triangles
    // at all (height points only) fall back to inverse-distance weighting.
    int uncovered = 0;
    final queue = <int>[];
    for (int k = 0; k < res * res; k++) {
      if (filled[k] != 0) {
        queue.add(k);
      } else {
        uncovered++;
      }
    }
    if (queue.isEmpty) {
      for (int j = 0; j < res; j++) {
        final z = -halfL + j * cellZ;
        for (int i = 0; i < res; i++) {
          heights[j * res + i] = _sampleHeightIdwWorld(-halfW + i * cellX, z);
        }
      }
    } else if (uncovered > 0) {
      for (int q = 0; q < queue.length; q++) {
        final k = queue[q];
        final i = k % res, j = k ~/ res;
        void spread(int ni, int nj) {
          if (ni < 0 || nj < 0 || ni >= res || nj >= res) return;
          final nk = nj * res + ni;
          if (filled[nk] != 0) return;
          heights[nk] = heights[k];
          filled[nk] = 1;
          queue.add(nk);
        }
        spread(i - 1, j);
        spread(i + 1, j);
        spread(i, j - 1);
        spread(i, j + 1);
      }
    }

    // Upload as an RGBA float texture (height in R) - the same format three_js
    // uses for bone matrices, so vertex-shader float textures are known to
    // work wherever skinned actors do. Nearest filtering: the shader does the
    // bilinear interpolation itself, because linear filtering of float
    // textures isn't supported everywhere (e.g. iOS).
    final data = THREE.Float32Array(res * res * 4);
    for (int k = 0; k < res * res; k++) {
      data[k * 4] = heights[k];
    }
    final texture = THREE.DataTexture(data, res, res, THREE.RGBAFormat, THREE.FloatType);
    texture.magFilter = THREE.NearestFilter;
    texture.minFilter = THREE.NearestFilter;
    texture.wrapS = THREE.ClampToEdgeWrapping;
    texture.wrapT = THREE.ClampToEdgeWrapping;
    texture.generateMipmaps = false;
    texture.flipY = false;
    texture.needsUpdate = true;

    _heightMap = heights;
    _heightMapRes = res;
    _heightMapTexture = texture;
    print('vegetation height map ${res}x$res, '
        '${_terrainTriangles.length} triangles, $uncovered points outside the terrain');
  }

  /// Bilinear lookup in the baked height map - same maths as the shader.
  double _sampleHeightMapWorld(double worldX, double worldZ) {
    final res = _heightMapRes;
    final map = _heightMap!;
    final halfW = max(_kBoundaryWidth / 2.0, 0.0001);
    final halfL = max(_kBoundaryLength / 2.0, 0.0001);
    final double gx = ((worldX + halfW) / (2.0 * halfW) * (res - 1)).clamp(0.0, (res - 1).toDouble()).toDouble();
    final double gz = ((worldZ + halfL) / (2.0 * halfL) * (res - 1)).clamp(0.0, (res - 1).toDouble()).toDouble();
    final i0 = gx.floor(), j0 = gz.floor();
    final i1 = min(i0 + 1, res - 1), j1 = min(j0 + 1, res - 1);
    final fx = gx - i0, fz = gz - j0;
    final h00 = map[j0 * res + i0], h10 = map[j0 * res + i1];
    final h01 = map[j1 * res + i0], h11 = map[j1 * res + i1];
    final h0 = h00 + (h10 - h00) * fx;
    final h1 = h01 + (h11 - h01) * fx;
    return h0 + (h1 - h0) * fz;
  }

  double? _sampleTriangulatedHeightWorld(double worldX, double worldZ) {
    const epsilon = 0.000001;

    for (final tri in _terrainTriangles) {
      final a = _terrainHeights[tri.a];
      final b = _terrainHeights[tri.b];
      final c = _terrainHeights[tri.c];

      final ax = a[0], az = a[1];
      final bx = b[0], bz = b[1];
      final cx = c[0], cz = c[1];

      final denom = ((bz - cz) * (ax - cx)) + ((cx - bx) * (az - cz));
      if (denom.abs() < epsilon) continue;

      final wA = ((bz - cz) * (worldX - cx) + (cx - bx) * (worldZ - cz)) / denom;
      final wB = ((cz - az) * (worldX - cx) + (ax - cx) * (worldZ - cz)) / denom;
      final wC = 1.0 - wA - wB;

      final inside = wA >= -epsilon && wB >= -epsilon && wC >= -epsilon;
      if (!inside) continue;

      return a[2] * wA + b[2] * wB + c[2] * wC;
    }

    return null;
  }

  double _sampleHeightIdwWorld(double worldX, double worldZ) {
    double weightSum = 0.0;
    double heightSum = 0.0;

    for (final pt in _terrainHeights) {
      final dx = worldX - pt[0];
      final dz = worldZ - pt[1];
      final dist2 = dx * dx + dz * dz;

      if (dist2 < 0.0001) {
        return pt[2];
      }

      final weight = 1.0 / dist2;
      weightSum += weight;
      heightSum += weight * pt[2];
    }

    return weightSum > 0.0 ? heightSum / weightSum : 0.0;
  }

  /// Transforms a [PlantSpec]'s world-space [excludeSquares] into the same
  /// local coordinate space used by the global exclusion squares, returning
  /// a normalised list of [x, z, width, length] entries ready for GPU upload
  /// and CPU scatter testing.
  List<List<double>> _processPlantExcludeSquares(
    PlantSpec spec,
    dynamic worldposx,
    dynamic worldposy,
  ) {
    if (spec.excludeSquares == null || spec.excludeSquares!.isEmpty) return [];
    return spec.excludeSquares!
        .take(_kMaxPlantExclusionSquares)
        .where((sq) => sq.length >= 3)
        .map((sq) {
          double lx = sq[0].toDouble();
          double lz = sq[1].toDouble();
          if (worldposx != null) {
            lx = -(worldposx - lx);
            lz = worldposy - lz;
          }
          final w = sq[2].toDouble();
          final l = (sq.length >= 4 ? sq[3] : sq[2]).toDouble();
          return [lx, lz, w, l];
        })
        .toList();
  }

    List<_TerrainTriangle> _buildTerrainTriangles() {
    if (_terrainHeights.length < 3) return [];

    const epsilon = 0.000001;
    final vertices = <_TriVertex>[];

    for (int i = 0; i < _terrainHeights.length; i++) {
      final pt = _terrainHeights[i];
      final alreadyExists = vertices.any((vertex) =>
          vertex.sourceIndex >= 0 &&
          (vertex.x - pt[0]).abs() < epsilon &&
          (vertex.z - pt[1]).abs() < epsilon);
      if (!alreadyExists) {
        vertices.add(_TriVertex(pt[0], pt[1], i));
      }
    }

    if (vertices.length < 3) return [];

    double minX = vertices.first.x;
    double maxX = vertices.first.x;
    double minZ = vertices.first.z;
    double maxZ = vertices.first.z;

    for (final vertex in vertices.skip(1)) {
      minX = min(minX, vertex.x);
      maxX = max(maxX, vertex.x);
      minZ = min(minZ, vertex.z);
      maxZ = max(maxZ, vertex.z);
    }

    final dx = maxX - minX;
    final dz = maxZ - minZ;
    final delta = max(dx, dz);
    final size = delta <= epsilon ? 1.0 : delta * 20.0;
    final midX = (minX + maxX) * 0.5;
    final midZ = (minZ + maxZ) * 0.5;
    // Looksl ike its adding the diagonal of the height points
    final superA = vertices.length;
    vertices.add(_TriVertex(midX - size, midZ - size, -1));
    final superB = vertices.length;
    vertices.add(_TriVertex(midX, midZ + size * 2.0, -2));
    final superC = vertices.length;
    vertices.add(_TriVertex(midX + size, midZ - size, -3));

    var triangles = <_IndexedTriangle>[
      _makeIndexedTriangle(vertices, superA, superB, superC),
    ];

    for (int pointIndex = 0; pointIndex < vertices.length - 3; pointIndex++) {
      final point = vertices[pointIndex];
      final badTriangles = <_IndexedTriangle>[];

      for (final triangle in triangles) {
        if (_pointInCircumcircle(point, triangle, vertices, epsilon)) {
          badTriangles.add(triangle);
        }
      }

      final edgeCounts = <String, _EdgeCount>{};
      for (final triangle in badTriangles) {
        for (final edge in triangle.edges) {
          final key = edge.key;
          final existing = edgeCounts[key];
          if (existing == null) {
            edgeCounts[key] = _EdgeCount(edge, 1);
          } else {
            edgeCounts[key] = _EdgeCount(existing.edge, existing.count + 1);
          }
        }
      }

      triangles = triangles.where((triangle) => !badTriangles.contains(triangle)).toList();

      for (final edgeCount in edgeCounts.values) {
        if (edgeCount.count != 1) continue;
        triangles.add(_makeIndexedTriangle(vertices, edgeCount.edge.a, edgeCount.edge.b, pointIndex));
      }
    }

    final terrainTriangles = <_TerrainTriangle>[];
    for (final triangle in triangles) {
      if (triangle.a >= vertices.length - 3 ||
          triangle.b >= vertices.length - 3 ||
          triangle.c >= vertices.length - 3) {
        continue;
      }

      final va = vertices[triangle.a];
      final vb = vertices[triangle.b];
      final vc = vertices[triangle.c];
      final area2 = ((vb.x - va.x) * (vc.z - va.z)) - ((vb.z - va.z) * (vc.x - va.x));
      if (area2.abs() < epsilon) continue;

      terrainTriangles.add(_TerrainTriangle(
        va.sourceIndex,
        vb.sourceIndex,
        vc.sourceIndex,
      ));
    }

    return terrainTriangles;
  }

  bool _pointInCircumcircle(
    _TriVertex point,
    _IndexedTriangle triangle,
    List<_TriVertex> vertices,
    double epsilon,
  ) {
    final a = vertices[triangle.a];
    final b = vertices[triangle.b];
    final c = vertices[triangle.c];

    final ax = a.x - point.x;
    final az = a.z - point.z;
    final bx = b.x - point.x;
    final bz = b.z - point.z;
    final cx = c.x - point.x;
    final cz = c.z - point.z;

    final det = (ax * ax + az * az) * (bx * cz - bz * cx)
              - (bx * bx + bz * bz) * (ax * cz - az * cx)
              + (cx * cx + cz * cz) * (ax * bz - az * bx);

    final orientation = ((b.x - a.x) * (c.z - a.z)) - ((b.z - a.z) * (c.x - a.x));
    if (orientation > 0.0) return det > epsilon;
    return det < -epsilon;
  }

  _IndexedTriangle _makeIndexedTriangle(
    List<_TriVertex> vertices,
    int a,
    int b,
    int c,
  ) {
    final va = vertices[a];
    final vb = vertices[b];
    final vc = vertices[c];
    final area2 = ((vb.x - va.x) * (vc.z - va.z)) - ((vb.z - va.z) * (vc.x - va.x));
    if (area2 >= 0.0) return _IndexedTriangle(a, b, c);
    return _IndexedTriangle(a, c, b);
  }

  double _convertRange(double val,
    double oldMin, double oldMax, double newMin, double newMax,
  ) => ((val - oldMin) * (newMax - newMin) / (oldMax - oldMin)) + newMin;
}

class _TerrainTriangle {
  const _TerrainTriangle(this.a, this.b, this.c);

  final int a;
  final int b;
  final int c;
}

class _TriVertex {
  const _TriVertex(this.x, this.z, this.sourceIndex);

  final double x;
  final double z;
  final int sourceIndex;
}

class _IndexedTriangle {
  const _IndexedTriangle(this.a, this.b, this.c);

  final int a;
  final int b;
  final int c;

  List<_Edge> get edges => [
    _Edge(a, b),
    _Edge(b, c),
    _Edge(c, a),
  ];
}

class _Edge {
  const _Edge(this.a, this.b);

  final int a;
  final int b;

  String get key {
    final minIndex = min(a, b);
    final maxIndex = max(a, b);
    return '$minIndex:$maxIndex';
  }
}

class _EdgeCount {
  const _EdgeCount(this.edge, this.count);

  final _Edge edge;
  final int count;
}
