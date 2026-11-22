// Modification of the threejs water shader to maker it faster
// Eg can specify what objects you want to reflect in the water
// You can specify how often you change the reflection
import 'dart:async';

import 'package:three_js_core/three_js_core.dart';
import 'package:three_js_core_loaders/three_js_core_loaders.dart';
import 'package:three_js_math/three_js_math.dart';
import './reflector.dart';
import './refractor.dart';

class WaterOptions{
  WaterOptions({
    this.color = 0xffffff,
    this.textureWidth = 512,
    this.textureHeight = 512,
    this.clipBias = 0.0,
    Map<String,dynamic>? shader,
    this.scale = 1,
    this.flowSpeed = 0.03,
    this.reflectivity = 0.02,
    Vector2? flowDirection,
    this.flowMap,
    FutureOr<Texture?>? normalMap0,
    FutureOr<Texture?>? normalMap1,
    this.inclusiveOnly = false,
    List<Object3D>? includeInReflection,
  }){
    this.includeInReflection = includeInReflection ?? [];
    this.shader = shader ?? Water.waterShader;
    this.flowDirection = flowDirection ?? Vector2( 1, 0 );

    final textureLoader = TextureLoader();
    this.normalMap0 = normalMap0 ?? textureLoader.fromAsset( 'assets/Water_1_M_Normal.jpg',package: 'three_js_objects');
    this.normalMap1 = normalMap1 ?? textureLoader.fromAsset( 'assets/Water_2_M_Normal.jpg',package: 'three_js_objects');
  }

  WaterOptions.fromMap(Map<String,dynamic> options){
    color = options['color'] ?? 0xFFFFFF;
		textureWidth = options['textureWidth'] ?? 512;
		textureHeight = options['textureHeight'] ?? 512;
		clipBias = options['clipBias'] ?? 0.0;
		flowDirection = options['flowDirection'] ?? Vector2( 1, 0 );
		flowSpeed = options['flowSpeed'] ?? 0.03;
		reflectivity = options['reflectivity'] ?? 0.02;
		scale = options['scale'] ?? 1;
		shader = options['shader'] ?? Water.waterShader;
		inclusiveOnly = options['inclusiveOnly'] ?? false;
		includeInReflection = List<Object3D>.from(options['includeInReflection'] ?? const <Object3D>[]);

		final textureLoader = TextureLoader();

		flowMap = options['flowMap'];
    if(options['normalMap0'] == null){
      textureLoader.fromAsset( 'assets/Water_1_M_Normal.jpg',package: 'three_js_objects').then((m){
        normalMap0 = m!;
      });
    }
    else{
      normalMap0 = options['normalMap0'];
    }

    if(options['normalMap1'] == null){
      textureLoader.fromAsset( 'assets/Water_2_M_Normal.jpg',package: 'three_js_objects').then((m){
        normalMap1 = m!;
      });
    }
    else{
      normalMap1 = options['normalMap1'];
    }
  }

  late int color;
  late int textureWidth;
  late int textureHeight;
  late double clipBias;
  late Vector2 flowDirection;
  late double flowSpeed;
  late double reflectivity;
  late double scale;
  late Map<String, dynamic> shader;
  late dynamic flowMap;
  late FutureOr<Texture?> normalMap0;
  late FutureOr<Texture?> normalMap1;

  /// If true, ONLY the objects in [includeInReflection] (and their children)
  /// are drawn in the reflection/refraction. Default false = current behaviour.
  bool inclusiveOnly = false;
  List<Object3D> includeInReflection = [];
}

/**
 * References:
 *	https://alex.vlachos.com/graphics/Vlachos-SIGGRAPH10-WaterFlow.pdf
 *	http://graphicsrunner.blogspot.de/2010/08/water-using-flow-maps.html
 *
 */

class Water extends Mesh {
  bool isWater = true;
  final cycle = 0.15;
  late double halfCycle;
  late double flowSpeed;
  final textureMatrix = Matrix4();
  final clock = Clock();

  // Set to e.g. 3 to only re-render reflection/refraction every N frames.
  int reflectionUpdateInterval = 1;

  // Objects to hide during reflection/refraction passes.
  // Populate once after scene load.
  List<Object3D> excludeFromReflection = [];

  // Inclusive mode: when true, only objects in includeInReflection (and their
  // children) are drawn in the reflection/refraction. Lights are always kept
  // so the reflection is lit the same as the main scene. excludeFromReflection
  // still applies, e.g. to hide one child of an included group.
  // Both can be changed at any time after creation.
  bool inclusiveOnly = false;
  List<Object3D> includeInReflection = [];

  Reflector? _reflector;
  Refractor? _refractor;
  int _frameCount = 0;
  bool _reflectionsReady = false;

	Water(super.geometry, [WaterOptions? options]) {
		type = 'Water';
    options ??= WaterOptions();
    inclusiveOnly = options.inclusiveOnly;
    includeInReflection = List<Object3D>.from(options.includeInReflection);
    _init(options);
  }
  
  Future<void> _init(WaterOptions options)async{
		final color = Color.fromHex32(options.color);
		final textureWidth = options.textureWidth;
		final textureHeight = options.textureHeight;
		final clipBias = options.clipBias;
		final flowDirection = options.flowDirection;
		flowSpeed = options.flowSpeed;
		final reflectivity = options.reflectivity;
		final scale = options.scale;
		final shader = options.shader;

		final flowMap = options.flowMap;
		final normalMap0 = await options.normalMap0;
		final normalMap1 = await options.normalMap1;

    halfCycle = cycle * 0.5;

		_reflector = Reflector( geometry, {
			'textureWidth': textureWidth,
			'textureHeight': textureHeight,
			'clipBias': clipBias
		} );

		_refractor = Refractor( geometry, {
			'textureWidth': textureWidth,
			'textureHeight': textureHeight,
			'clipBias': clipBias
		} );

		_reflector!.matrixAutoUpdate = false;
		_refractor!.matrixAutoUpdate = false;

		// material

		material = ShaderMaterial.fromMap( {
      'name': shader['name'],
			'uniforms': UniformsUtils.merge( [
				uniformsLib[ 'fog' ],
				shader['uniforms']
			] ),
			'vertexShader': shader['vertexShader'],
			'fragmentShader': shader['fragmentShader'],
			'transparent': true,
			'fog': true
		} );

		if ( flowMap != null ) {
			material?.defines?['USE_FLOWMAP'] = '';
			material?.uniforms[ 'tFlowMap' ] = {
				'type': 't',
				'value': flowMap
			};
		}
    else {
			material?.uniforms[ 'flowDirection' ] = {
				'type': 'v2',
				'value': flowDirection
			};
		}

		// maps

		normalMap0?.wrapS = RepeatWrapping;
		normalMap1?.wrapS = RepeatWrapping;
		normalMap0?.wrapT = RepeatWrapping;
		normalMap1?.wrapT = RepeatWrapping;

		material?.uniforms[ 'tReflectionMap' ]['value'] = _reflector!.getRenderTarget().texture;
		material?.uniforms[ 'tRefractionMap' ]['value'] = _refractor!.getRenderTarget().texture;
    _reflectionsReady = true;
		material?.uniforms[ 'tNormalMap0' ]['value'] = normalMap0;
		material?.uniforms[ 'tNormalMap1' ]['value'] = normalMap1;

		// water

		material?.uniforms[ 'color' ]['value'] = color;
		material?.uniforms[ 'reflectivity' ]['value'] = reflectivity;
		material?.uniforms[ 'textureMatrix' ]['value'] = textureMatrix;

		// inital values

		material?.uniforms[ 'config' ]['value'].x = 0.0; // flowMapOffset0
		material?.uniforms[ 'config' ]['value'].y = halfCycle; // flowMapOffset1
		material?.uniforms[ 'config' ]['value'].z = halfCycle; // halfCycle
		material?.uniforms[ 'config' ]['value'].w = scale*1.0; // scale

    // onAfterRender only handles cheap per-frame uniform updates.
    // Reflection/refraction renders have been moved to updateReflections()
    // which must be called from your animate loop BEFORE renderer.render().
    // This prevents the nested render-inside-render that corrupts Three.js's
    // transparent object sort order and causes cloud/sky flickering.
    onAfterRender = ({Camera? camera, BufferGeometry? geometry, Map<String, dynamic>? group, Material? material, Object3D? mesh, RenderTarget? renderTarget, WebGLRenderer? renderer, Scene? scene}){
      updateTextureMatrix( camera! );
      updateFlow();
    };
  }

  /// Call this BEFORE renderer.render() in your animate loop.
  /// Renders the reflection and refraction passes with clean renderer state
  /// so they don't interfere with transparent objects in the main pass.
  ///
  /// Example in animate():
  ///   wateri.updateReflections(threeJs.renderer!, threeJs.scene, threeJs.camera);
  ///   // ... then three_js renders normally
  void updateReflections(WebGLRenderer renderer, Scene scene, Camera camera) {
    if (!_reflectionsReady || _reflector == null || _refractor == null) return;
    if (!visible) return;

    _frameCount++;
    if (_frameCount % reflectionUpdateInterval != 0) return;

    // Update texture matrix now so it is ready when the main pass draws water.
    updateTextureMatrix(camera);

    // Hide excluded objects before reflection passes.
    final List<Object3D> hidden = [];
    for (final obj in excludeFromReflection) {
      if (obj.visible) {
        obj.visible = false;
        hidden.add(obj);
      }
    }

    // Inclusive mode: hide everything that isn't in includeInReflection.
    if (inclusiveOnly) {
      _hideAllExceptIncluded(scene, hidden);
    }

    // Hide the water itself so it doesn't appear in its own reflection.
    visible = false;

    _reflector!.matrixWorld.setFrom(matrixWorld);
    _refractor!.matrixWorld.setFrom(matrixWorld);

    _reflector!.onAfterRender!(renderer: renderer, scene: scene, camera: camera);
    _refractor!.onAfterRender!(renderer: renderer, scene: scene, camera: camera);

    visible = true;

    // Restore excluded objects.
    for (final obj in hidden) {
      obj.visible = true;
    }
  }

  /// Hides every object in [scene] except those in [includeInReflection]
  /// (with their children) and lights. Anything hidden is added to [hidden]
  /// so updateReflections() can restore it afterwards.
  ///
  /// Hiding a parent hides all its children, so the parents of an included
  /// object can't be hidden. Instead they stay visible and we step inside
  /// them, hiding their other children. Anything not on the way to an
  /// included object is hidden in one go, which keeps this cheap.
  void _hideAllExceptIncluded(Scene scene, List<Object3D> hidden) {
    final include = <Object3D>{};
    final onPathToIncluded = <Object3D>{};
    for (final obj in includeInReflection) {
      include.add(obj);
      Object3D? p = obj.parent;
      while (p != null && p != scene && onPathToIncluded.add(p)) {
        p = p.parent;
      }
    }
    _hideChildren(scene, include, onPathToIncluded, hidden);
  }

  void _hideChildren(Object3D node, Set<Object3D> include,
      Set<Object3D> onPathToIncluded, List<Object3D> hidden) {
    for (final child in node.children) {
      if (!child.visible) continue;              // already hidden
      if (include.contains(child)) continue;     // keep it and all its children
      if (child is Light) continue;              // keep lighting the same
      if (onPathToIncluded.contains(child)) {
        // Keep this parent visible, but hide its non-included children.
        _hideChildren(child, include, onPathToIncluded, hidden);
        continue;
      }
      child.visible = false;
      hidden.add(child);
    }
  }
  void updateTextureMatrix(Camera camera ) {
    textureMatrix.setValues(
      0.5, 0.0, 0.0, 0.5,
      0.0, 0.5, 0.0, 0.5,
      0.0, 0.0, 0.5, 0.5,
      0.0, 0.0, 0.0, 1.0
    );

    textureMatrix.multiply( camera.projectionMatrix );
    textureMatrix.multiply( camera.matrixWorldInverse );
    textureMatrix.multiply( this.matrixWorld );
  }

  void updateFlow() {
    final delta = clock.getDelta();
    final config = material?.uniforms[ 'config' ];

    config['value'].x += flowSpeed * delta; // flowMapOffset0
    config['value'].y = config['value'].x + halfCycle; // flowMapOffset1

    // Important: The distance between offsets should be always the value of "halfCycle".
    // Moreover, both offsets should be in the range of [ 0, cycle ].
    // This approach ensures a smooth water flow and avoids "reset" effects.

    if ( config['value'].x >= cycle ) {
      config['value'].x = 0.0;
      config['value'].y = halfCycle;
    } else if ( config['value'].y >= cycle ) {
      config['value'].y = config['value'].y - cycle;
    }
  }

  static Map<String,dynamic> waterShader = {
    'uniforms': {
      'color': {
        'type': 'c',
        'value': null
      },
      'reflectivity': {
        'type': 'f',
        'value': 0
      },
      'tReflectionMap': {
        'type': 't',
        'value': null
      },
      'tRefractionMap': {
        'type': 't',
        'value': null
      },
      'tNormalMap0': {
        'type': 't',
        'value': null
      },
      'tNormalMap1': {
        'type': 't',
        'value': null
      },
      'textureMatrix': {
        'type': 'm4',
        'value': null
      },
      'config': {
        'type': 'v4',
        'value': Vector4.identity()
      }
    },

    'vertexShader': '''
      #include <common>
      #include <fog_pars_vertex>
      #include <logdepthbuf_pars_vertex>

      uniform mat4 textureMatrix;

      varying vec4 vCoord;
      varying vec2 vUv;
      varying vec3 vToEye;

      void main() {

        vUv = uv;
        vCoord = textureMatrix * vec4( position, 1.0 );

        vec4 worldPosition = modelMatrix * vec4( position, 1.0 );
        vToEye = cameraPosition - worldPosition.xyz;

        vec4 mvPosition =  viewMatrix * worldPosition; // used in fog_vertex
        gl_Position = projectionMatrix * mvPosition;

        #include <logdepthbuf_vertex>
        #include <fog_vertex>

      }''',

    'fragmentShader':'''
      #include <common>
      #include <fog_pars_fragment>
      #include <logdepthbuf_pars_fragment>

      uniform sampler2D tReflectionMap;
      uniform sampler2D tRefractionMap;
      uniform sampler2D tNormalMap0;
      uniform sampler2D tNormalMap1;

      #ifdef USE_FLOWMAP
        uniform sampler2D tFlowMap;
      #else
        uniform vec2 flowDirection;
      #endif

      uniform vec3 color;
      uniform float reflectivity;
      uniform vec4 config;

      varying vec4 vCoord;
      varying vec2 vUv;
      varying vec3 vToEye;

      void main() {

        #include <logdepthbuf_fragment>

        float flowMapOffset0 = config.x;
        float flowMapOffset1 = config.y;
        float halfCycle = config.z;
        float scale = config.w;

        vec3 toEye = normalize( vToEye );

        // determine flow direction
        vec2 flow;
        #ifdef USE_FLOWMAP
          flow = texture2D( tFlowMap, vUv ).rg * 2.0 - 1.0;
        #else
          flow = flowDirection;
        #endif
        flow.x *= - 1.0;

        // sample normal maps (distort uvs with flowdata)
        vec4 normalColor0 = texture2D( tNormalMap0, ( vUv * scale ) + flow * flowMapOffset0 );
        vec4 normalColor1 = texture2D( tNormalMap1, ( vUv * scale ) + flow * flowMapOffset1 );

        // linear interpolate to get the final normal color
        float flowLerp = abs( halfCycle - flowMapOffset0 ) / halfCycle;
        vec4 normalColor = mix( normalColor0, normalColor1, flowLerp );

        // calculate normal vector
        vec3 normal = normalize( vec3( normalColor.r * 2.0 - 1.0, normalColor.b,  normalColor.g * 2.0 - 1.0 ) );

        // calculate the fresnel term to blend reflection and refraction maps
        float theta = max( dot( toEye, normal ), 0.0 );
        float reflectance = reflectivity + ( 1.0 - reflectivity ) * pow( ( 1.0 - theta ), 5.0 );

        // calculate final uv coords
        vec3 coord = vCoord.xyz / vCoord.w;
        vec2 uv = coord.xy + coord.z * normal.xz * 0.05;

        vec4 reflectColor = texture2D( tReflectionMap, vec2( 1.0 - uv.x, uv.y ) );
        vec4 refractColor = texture2D( tRefractionMap, uv );

        // multiply water color with the mix of both textures
        gl_FragColor = vec4( color, 1.0 ) * mix( refractColor, reflectColor, reflectance );

        #include <tonemapping_fragment>
        #include <colorspace_fragment>
        #include <fog_fragment>

      }'''
  };
}