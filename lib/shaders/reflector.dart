//import 'package:three_js_core/three_js_core.dart';
//import 'package:three_js_math/three_js_math.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;

import '../openworld.dart' as OPENWORLD;


class Reflector extends THREE.Mesh {
  final bool isReflector = true;
  late THREE.WebGLRenderTarget renderTarget;
	THREE.PerspectiveCamera camera = THREE.PerspectiveCamera();

	Reflector(super.geometry, [Map<String,dynamic>? options] ) {
    options ??= {};
		type = 'Reflector';

		final scope = this;

		final color = THREE.Color.fromHex( options['color'] ?? 0x7F7F7F);
		final textureWidth = options['textureWidth'] ?? 512;
		final textureHeight = options['textureHeight'] ?? 512;
		final clipBias = options['clipBias'] ?? 0;
		final shader = options['shader'] ?? Reflector.reflectorShader;
		final multisample = options['multisample'] ?? 4;

		final reflectorPlane = THREE.Plane();
		final normal = THREE.Vector3();
		final reflectorWorldPosition = THREE.Vector3();
		final cameraWorldPosition = THREE.Vector3();
		final rotationMatrix = THREE.Matrix4();
		final lookAtPosition = THREE.Vector3( 0, 0, - 1 );
		final clipPlane = THREE.Vector4();

		final view = THREE.Vector3();
		final target = THREE.Vector3();
		final q = THREE.Vector4();

		final textureMatrix = THREE.Matrix4();
		final THREE.PerspectiveCamera virtualCamera = camera;

	  renderTarget = THREE.WebGLRenderTarget( textureWidth, textureHeight, THREE.WebGLRenderTargetOptions({'samples': multisample, 'type': THREE.HalfFloatType }));

		material =  THREE.ShaderMaterial( {
			'name': shader['name'] ?? 'unspecified',
			'uniforms': THREE.UniformsUtils.clone( shader['uniforms'] ),
			'fragmentShader': shader['fragmentShader'],
			'vertexShader': shader['vertexShader']
		} );

		material?.uniforms[ 'tDiffuse' ]['value'] = renderTarget.texture;
		material?.uniforms[ 'color' ]['value'] = color;
		material?.uniforms[ 'textureMatrix' ]['value'] = textureMatrix;

		onBeforeRender = ({
			THREE.WebGLRenderer? renderer,
			THREE.RenderTarget? renderTarget,
			THREE.Object3D? mesh,
			THREE.Scene? scene,
			THREE.Camera? camera,
			THREE.BufferGeometry? geometry,
			THREE.Material? material,
      Map<String, dynamic>? group
    }){
			reflectorWorldPosition.setFromMatrixPosition( scope.matrixWorld );
			cameraWorldPosition.setFromMatrixPosition( camera!.matrixWorld );

			rotationMatrix.extractRotation( scope.matrixWorld );

			normal.set( 0, 0, 1 );
			normal.applyMatrix4( rotationMatrix );

			view.subVectors( reflectorWorldPosition, cameraWorldPosition );

			// Avoid rendering when reflector is facing away

			if ( view.dot( normal ) > 0 ) return;

			view.reflect( normal ).negate();
			view.add( reflectorWorldPosition );

			rotationMatrix.extractRotation( camera.matrixWorld );

			lookAtPosition.set( 0, 0, - 1 );
			lookAtPosition.applyMatrix4( rotationMatrix );
			lookAtPosition.add( cameraWorldPosition );

			target.subVectors( reflectorWorldPosition, lookAtPosition );
			target.reflect( normal ).negate();
			target.add( reflectorWorldPosition );

			virtualCamera.position.copy(view);//.copy();
			virtualCamera.up.set( 0, 1, 0 );
			virtualCamera.up.applyMatrix4( rotationMatrix );
			virtualCamera.up.reflect( normal );
			virtualCamera.lookAt( target );

			virtualCamera.far = camera.far; // Used in WebGLBackground

			virtualCamera.updateMatrixWorld();
			virtualCamera.projectionMatrix.copy( camera.projectionMatrix );

			// Update the texture matrix
			textureMatrix.set(
				0.5, 0.0, 0.0, 0.5,
				0.0, 0.5, 0.0, 0.5,
				0.0, 0.0, 0.5, 0.5,
				0.0, 0.0, 0.0, 1.0
			);
			textureMatrix.multiply( virtualCamera.projectionMatrix );
			textureMatrix.multiply( virtualCamera.matrixWorldInverse );
			textureMatrix.multiply( scope.matrixWorld );

			// Now update projection matrix with clip plane, implementing code from: http://www.terathon.com/code/oblique.html
			// Paper explaining this technique: http://www.terathon.com/lengyel/Lengyel-Oblique.pdf
			reflectorPlane.setFromNormalAndCoplanarPoint( normal, reflectorWorldPosition );
			reflectorPlane.applyMatrix4( virtualCamera.matrixWorldInverse );

			clipPlane.set( reflectorPlane.normal.x, reflectorPlane.normal.y, reflectorPlane.normal.z, reflectorPlane.constant );

			final projectionMatrix = virtualCamera.projectionMatrix;

			q.x = (clipPlane.x.sign + projectionMatrix.elements[ 8 ] ) / projectionMatrix.elements[ 0 ];
			q.y = (clipPlane.y.sign + projectionMatrix.elements[ 9 ] ) / projectionMatrix.elements[ 5 ];
			q.z = - 1.0;
			q.w = ( 1.0 + projectionMatrix.elements[ 10 ] ) / projectionMatrix.elements[ 14 ];

			// Calculate the scaled plane vector

			clipPlane.multiplyScalar( 2.0 / clipPlane.dot( q ) );

			// Replacing the third row of the projection matrix
			projectionMatrix.elements[ 2 ] = clipPlane.x.toDouble();
			projectionMatrix.elements[ 6 ] = clipPlane.y.toDouble();
			projectionMatrix.elements[ 10 ] = clipPlane.z + 1.0 - clipBias;
			projectionMatrix.elements[ 14 ] = clipPlane.w.toDouble();

			// Render
			scope.visible = false;

			final currentRenderTarget = renderer?.getRenderTarget();

			final currentXrEnabled = renderer?.xr.enabled;
			final currentShadowAutoUpdate = renderer?.shadowMap.autoUpdate;

			renderer?.xr.enabled = false; // Avoid camera modification
			renderer?.shadowMap.autoUpdate = false; // Avoid re-computing shadows

			renderer?.setRenderTarget( renderTarget );

			renderer?.state.buffers['depth'].setMask( true ); // make sure the depth buffer is writable so it can be properly cleared, see #18897

			if ( renderer?.autoClear == false ) renderer?.clear();
			//print("ooo"+scene.toString()+" "+virtualCamera.toString()+" "+renderer.toString());
			renderer?.render( scene!, virtualCamera );

			renderer?.xr.enabled = currentXrEnabled!;
			renderer?.shadowMap.autoUpdate = currentShadowAutoUpdate!;

			renderer?.setRenderTarget( currentRenderTarget );

			// Restore viewport

			//final viewport = camera.viewport;

		//	if ( viewport != null ) {
			// why x 2?
				renderer?.state.viewport(THREE.Vector4(0, 0,OPENWORLD.Camera.width*2, OPENWORLD.Camera.height*2));// viewport );
			//}

			scope.visible = true;
		};
	}

  THREE.WebGLRenderTarget getRenderTarget() {
    return renderTarget;
  }

  @override
  void dispose() {
    renderTarget.dispose();
    material?.dispose();
  }

  static Map<String,dynamic> reflectorShader = {

    'name': 'ReflectorShader',

    'uniforms': {

      'color': {
        'value': null
      },

      'tDiffuse': {
        'value': null
      },

      'textureMatrix': {
        'value': null
      }

    },

    'vertexShader': /* glsl */'''
      uniform mat4 textureMatrix;
      varying vec4 vUv;

      #include <common>
      #include <logdepthbuf_pars_vertex>

      void main() {

        vUv = textureMatrix * vec4( position, 1.0 );

        gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

        #include <logdepthbuf_vertex>

      }''',

    'fragmentShader': /* glsl */'''
      uniform vec3 color;
      uniform sampler2D tDiffuse;
      varying vec4 vUv;

      #include <logdepthbuf_pars_fragment>

      float blendOverlay( float base, float blend ) {

        return( base < 0.5 ? ( 2.0 * base * blend ) : ( 1.0 - 2.0 * ( 1.0 - base ) * ( 1.0 - blend ) ) );

      }

      vec3 blendOverlay( vec3 base, vec3 blend ) {

        return vec3( blendOverlay( base.r, blend.r ), blendOverlay( base.g, blend.g ), blendOverlay( base.b, blend.b ) );

      }

      void main() {

        #include <logdepthbuf_fragment>

        vec4 base = texture2DProj( tDiffuse, vUv );
        gl_FragColor = vec4( blendOverlay( base.rgb, color ), 1.0 );

        #include <tonemapping_fragment>
        #include <colorspace_fragment>

      }'''
  };

}
