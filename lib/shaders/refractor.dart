import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;
import '../openworld.dart' as OPENWORLD;

import 'reflector.dart';

class Refractor extends THREE.Mesh {
  final bool isRefractor = true;
  late THREE.WebGLRenderTarget renderTarget;
	THREE.PerspectiveCamera camera = THREE.PerspectiveCamera();

	late double width;
	late double height;
	Refractor(super.geometry, [Map<String,dynamic>? options] ) {
		type = 'Refractor';
		FlutterView view = WidgetsBinding.instance.platformDispatcher.views.first;

		Size size = view.physicalSize;
		width = size.width;
		height = size.height;
		//print("xxxx"+size.width.toString());
    options ??= {};

		final scope = this;

		final color = THREE.Color.fromHex( options['color'] ?? 0x7F7F7F);
		final textureWidth = options['textureWidth'] ?? 512;
		final textureHeight = options['textureHeight'] ?? 512;
		final clipBias = options['clipBias'] ?? 0;
		final shader = options['shader'] ?? Reflector.reflectorShader;
		final multisample = options['multisample'] ?? 4;
		//

		final virtualCamera = camera;
		virtualCamera.matrixAutoUpdate = false;
		virtualCamera.userData['refractor'] = true;

		final refractorPlane = THREE.Plane();
		final textureMatrix = THREE.Matrix4();

		// render target

		renderTarget = THREE.WebGLRenderTarget( textureWidth, textureHeight, THREE.WebGLRenderTargetOptions({'samples': multisample, 'type': THREE.HalfFloatType}));

		// material

		material = THREE.ShaderMaterial( {
			'uniforms': THREE.UniformsUtils.clone( shader['uniforms'] ),
			'vertexShader': shader['vertexShader'],
			'fragmentShader': shader['fragmentShader'],
			'transparent': true // ensures, refractors are drawn from farthest to closest
		} );

		material?.uniforms[ 'color' ]['value'] = color;
		material?.uniforms[ 'tDiffuse' ]['value'] = renderTarget.texture;
		material?.uniforms[ 'textureMatrix' ]['value'] = textureMatrix;

		// functions

		final visible = (() {

			final refractorWorldPosition = THREE.Vector3();
			final cameraWorldPosition = THREE.Vector3();
			final rotationMatrix = THREE.Matrix4();

			final view = THREE.Vector3();
			final normal = THREE.Vector3();

			return ( camera ) {

				refractorWorldPosition.setFromMatrixPosition( scope.matrixWorld );
				cameraWorldPosition.setFromMatrixPosition( camera.matrixWorld );

				view.subVectors( refractorWorldPosition, cameraWorldPosition );

				rotationMatrix.extractRotation( scope.matrixWorld );

				normal.set( 0, 0, 1 );
				normal.applyMatrix4( rotationMatrix );

				return view.dot( normal ) < 0;

			};

		})();

		final updateRefractorPlane = (() {

			final normal = THREE.Vector3();
			final position = THREE.Vector3();
			final quaternion = THREE.Quaternion();
			final scale = THREE.Vector3();

			return() {

				scope.matrixWorld.decompose( position, quaternion, scale );
				normal.set( 0, 0, 1 ).applyQuaternion( quaternion ).normalize();

				// flip the normal because we want to cull everything above the plane

				normal.negate();

				refractorPlane.setFromNormalAndCoplanarPoint( normal, position );

			};

		})();

		final updateVirtualCamera = (() {

			final clipPlane = THREE.Plane();
			final clipVector = THREE.Vector4();
			final q = THREE.Vector4();

			return (THREE.Camera camera ) {

				virtualCamera.matrixWorld.copy( camera.matrixWorld );
				virtualCamera.matrixWorldInverse.copy( virtualCamera.matrixWorld ).invert();
				virtualCamera.projectionMatrix.copy( camera.projectionMatrix );
				virtualCamera.far = camera.far; // used in WebGLBackground

				// The following code creates an oblique view frustum for clipping.
				// see: Lengyel, Eric. “Oblique View Frustum Depth Projection and Clipping”.
				// Journal of Game Development, Vol. 1, No. 2 (2005), Charles River Media, pp. 5–16

				clipPlane.copy( refractorPlane );
				clipPlane.applyMatrix4( virtualCamera.matrixWorldInverse );

				clipVector.set( clipPlane.normal.x, clipPlane.normal.y, clipPlane.normal.z, clipPlane.constant );

				// calculate the clip-space corner point opposite the clipping plane and
				// transform it into camera space by multiplying it by the inverse of the projection matrix

				final projectionMatrix = virtualCamera.projectionMatrix;

				q.x = (clipVector.x.sign + projectionMatrix.elements[ 8 ] ) / projectionMatrix.elements[ 0 ];
				q.y = (clipVector.y.sign + projectionMatrix.elements[ 9 ] ) / projectionMatrix.elements[ 5 ];
				q.z = - 1.0;
				q.w = ( 1.0 + projectionMatrix.elements[ 10 ] ) / projectionMatrix.elements[ 14 ];

				// calculate the scaled plane vector

				clipVector.multiplyScalar( 2.0 / clipVector.dot( q ) );

				// replacing the third row of the projection matrix

				projectionMatrix.elements[ 2 ] = clipVector.x.toDouble();
				projectionMatrix.elements[ 6 ] = clipVector.y.toDouble();
				projectionMatrix.elements[ 10 ] = clipVector.z.toDouble() + 1.0 - clipBias;
				projectionMatrix.elements[ 14 ] = clipVector.w.toDouble();

			};

		} )();

		// This will update the texture matrix that is used for projective texture mapping in the shader.
		// see: http://developer.download.nvidia.com/assets/gamedev/docs/projective_texture_mapping.pdf

		void updateTextureMatrix(THREE.Camera camera ) {
			// this matrix does range mapping to [ 0, 1 ]

			textureMatrix.set(
				0.5, 0.0, 0.0, 0.5,
				0.0, 0.5, 0.0, 0.5,
				0.0, 0.0, 0.5, 0.5,
				0.0, 0.0, 0.0, 1.0
			);

			// we use "Object Linear Texgen", so we need to multiply the texture matrix T
			// (matrix above) with the projection and view matrix of the virtual camera
			// and the model matrix of the refractor

			textureMatrix.multiply( camera.projectionMatrix );
			textureMatrix.multiply( camera.matrixWorldInverse );
			textureMatrix.multiply( scope.matrixWorld );
		}

		//

		void render(THREE.WebGLRenderer renderer, THREE.Object3D scene, THREE.Camera camera ) {

			scope.visible = false;

			final currentRenderTarget = renderer.getRenderTarget();
			final currentXrEnabled = renderer.xr.enabled;
			final currentShadowAutoUpdate = renderer.shadowMap.autoUpdate;

			renderer.xr.enabled = false; // avoid camera modification
			renderer.shadowMap.autoUpdate = false; // avoid re-computing shadows

			renderer.setRenderTarget( renderTarget );
			if ( renderer.autoClear == false ) renderer.clear();
			renderer.render( scene, virtualCamera );

			renderer.xr.enabled = currentXrEnabled;
			renderer.shadowMap.autoUpdate = currentShadowAutoUpdate;
			renderer.setRenderTarget( currentRenderTarget );

			// restore viewport

		//	final viewport = camera.viewport;

			//if ( viewport != null ) {
			//why x 3?
			renderer?.state.viewport(THREE.Vector4(0, 0,width, height));//OPENWORLD.Camera.width*3, OPENWORLD.Camera.height*3));// viewport );
		//	renderer.state.viewport( viewport );
			//}

			scope.visible = true;
		}

		//

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

			// ensure refractors are rendered only once per frame

			if ( camera?.userData['refractor'] == true ) return;
			// avoid rendering when the refractor is viewed from behind
			if ( !visible( camera ) == true ) return;

			// update

			updateRefractorPlane();
			updateTextureMatrix( camera! );
			updateVirtualCamera( camera );
			render( renderer!, scene!, camera );
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

  static Map<String,dynamic> refractorShader = {
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

      void main() {

        vUv = textureMatrix * vec4( position, 1.0 );
        gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );

      }''',

    'fragmentShader': /* glsl */'''

      uniform vec3 color;
      uniform sampler2D tDiffuse;

      varying vec4 vUv;

      float blendOverlay( float base, float blend ) {

        return( base < 0.5 ? ( 2.0 * base * blend ) : ( 1.0 - 2.0 * ( 1.0 - base ) * ( 1.0 - blend ) ) );

      }

      vec3 blendOverlay( vec3 base, vec3 blend ) {

        return vec3( blendOverlay( base.r, blend.r ), blendOverlay( base.g, blend.g ), blendOverlay( base.b, blend.b ) );

      }

      void main() {

        vec4 base = texture2DProj( tDiffuse, vUv );
        gl_FragColor = vec4( blendOverlay( base.rgb, color ), 1.0 );

        #include <tonemapping_fragment>
        #include <colorspace_fragment>

      }'''

  };

}