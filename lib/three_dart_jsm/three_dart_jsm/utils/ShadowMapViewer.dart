part of jsm_utils;

// import { UnpackDepthRGBAShader } from '../shaders/UnpackDepthRGBAShader.js';

/**
 * This is a helper for visualising a given light's shadow map.
 * It works for shadow casting lights: DirectionalLight and SpotLight.
 * It renders out the shadow map and displays it on a HUD.
 *
 * Example usage:
 *	1) Import ShadowMapViewer into your app.
 *
 *	2) Create a shadow casting light and name it optionally:
 *		var light = new DirectionalLight( 0xffffff, 1 );
 *		light.castShadow = true;
 *		light.name = 'Sun';
 *
 *	3) Create a shadow map viewer for that light and set its size and position optionally:
 *		var shadowMapViewer = new ShadowMapViewer( light );
 *		shadowMapViewer.size.set( 128, 128 );	//width, height  default: 256, 256
 *		shadowMapViewer.position.set( 10, 10 );	//x, y in pixel	 default: 0, 0 (top left corner)
 *
 *	4) Render the shadow map viewer in your render loop:
 *		shadowMapViewer.render( renderer );
 *
 *	5) Optionally: Update the shadow map viewer on window resize:
 *		shadowMapViewer.updateForWindowResize();
 *
 *	6) If you set the position or size members directly, you need to call shadowMapViewer.update();
 */

class ShadowMapViewer {
  //- API
  // Set to false to disable displaying this shadow map
  bool enabled = true;
  bool userAutoClearSetting = false;

  late Map<String, num> size;
  late Map<String, num> position;
  late Mesh mesh;

  late num innerHeight;
  late num innerWidth;

  late Map<String, num> frame;
  late Map<String, dynamic> uniforms;

  late Scene scene;
  late OrthographicCamera camera;

  late Light light;

  ShadowMapViewer(light, innerWidth, innerHeight) {
    this.light = light;
    this.innerWidth = innerWidth;
    this.innerHeight = innerHeight;

    //- Internals
    var scope = this;
    var doRenderLabel = (light.name != null && light.name != '');

    //Holds the initial position and dimension of the HUD
    frame = {"x": 10, "y": 10, "width": 256, "height": 256};

    camera = new OrthographicCamera(innerWidth / -2, innerWidth / 2,
        innerHeight / 2, innerHeight / -2, 1, 10);
    camera.position.set(0, 0, 2);
    scene = new Scene();
    // scene.background = Color.fromHex(0xff00ff);

    //HUD for shadow map
    var shader = UnpackDepthRGBAShader;

    uniforms = UniformsUtils.clone(shader["uniforms"]);
    var material = new ShaderMaterial({
      "uniforms": uniforms,
      "vertexShader": shader["vertexShader"],
      "fragmentShader": shader["fragmentShader"]
    });
    var plane = new PlaneGeometry(frame["width"]!, frame["height"]!);
    mesh = new Mesh(plane, material);

    scene.add(mesh);

    //Label for light's name
    var labelCanvas, labelMesh;

    // if ( doRenderLabel ) {

    // 	labelCanvas = document.createElement( 'canvas' );

    // 	var context = labelCanvas.getContext( '2d' );
    // 	context.font = 'Bold 20px Arial';

    // 	var labelWidth = context.measureText( light.name ).width;
    // 	labelCanvas.width = labelWidth;
    // 	labelCanvas.height = 25;	//25 to account for g, p, etc.

    // 	context.font = 'Bold 20px Arial';
    // 	context.fillStyle = 'rgba( 255, 0, 0, 1 )';
    // 	context.fillText( light.name, 0, 20 );

    // 	var labelTexture = new Texture( labelCanvas );
    // 	labelTexture.magFilter = LinearFilter;
    // 	labelTexture.minFilter = LinearFilter;
    // 	labelTexture.needsUpdate = true;

    // 	var labelMaterial = new MeshBasicMaterial( { map: labelTexture, side: DoubleSide } );
    // 	labelMaterial.transparent = true;

    // 	var labelPlane = new PlaneGeometry( labelCanvas.width, labelCanvas.height );
    // 	labelMesh = new Mesh( labelPlane, labelMaterial );

    // 	scene.add( labelMesh );

    // }

    // Set the size of the displayed shadow map on the HUD
    this.size = {"width": frame["width"]!, "height": frame["height"]!};
    // this.size = {
    // 	width: frame.width,
    // 	height: frame.height,
    // 	set: function ( width, height ) {

    // 		this.width = width;
    // 		this.height = height;

    // 		mesh.scale.set( this.width / frame.width, this.height / frame.height, 1 );

    // 		//Reset the position as it is off when we scale stuff
    // 		resetPosition();

    // 	}
    // };

    // Set the position of the displayed shadow map on the HUD
    this.position = {"x": frame["x"]!, "y": frame["y"]!};
    // this.position = {
    // 	x: frame.x,
    // 	y: frame.y,
    // 	set: function ( x, y ) {

    // 		this.x = x;
    // 		this.y = y;

    // 		var width = scope.size.width;
    // 		var height = scope.size.height;

    // 		mesh.position.set( - window.innerWidth / 2 + width / 2 + this.x, window.innerHeight / 2 - height / 2 - this.y, 0 );

    // 		if ( doRenderLabel ) labelMesh.position.set( mesh.position.x, mesh.position.y - scope.size.height / 2 + labelCanvas.height / 2, 0 );

    // 	}
    // };

    //Force an update to set position/size
    this.update();
  }

  setPosition(x, y) {
    this.position["x"] = x;
    this.position["y"] = y;

    var width = this.size["width"]!;
    var height = this.size["height"]!;

    mesh.position.set(
        -innerWidth / 2 + width / 2 + x, innerHeight / 2 - height / 2 - y, 0);

    // if ( doRenderLabel ) labelMesh.position.set( mesh.position.x, mesh.position.y - scope.size.height / 2 + labelCanvas.height / 2, 0 );
  }

  setSize(width, height) {
    this.size["width"] = width;
    this.size["height"] = height;

    mesh.scale.set(width / frame["width"], height / frame["height"], 1);

    //Reset the position as it is off when we scale stuff
    resetPosition();
  }

  resetPosition() {
    this.setPosition(this.position["x"], this.position["x"]);
  }

  update() {
    this.setPosition(this.position["x"], this.position["y"]);
    this.setSize(this.size["width"], this.size["height"]);
  }

  render(renderer) {
    if (this.enabled) {
      print("shadowmap view render   ");

      //Because a light's .shadowMap is only initialised after the first render pass
      //we have to make sure the correct map is sent into the shader, otherwise we
      //always end up with the scene's first added shadow casting light's shadowMap
      //in the shader
      //See: https://github.com/mrdoob/three.js/issues/5932
      uniforms["tDiffuse"]["value"] = light.shadow!.map!.texture;

      userAutoClearSetting = renderer.autoClear;
      renderer.autoClear = false; // To allow render overlay
      renderer.clearDepth();
      renderer.render(scene, camera);
      renderer.autoClear = userAutoClearSetting; //Restore user's setting

    }
  }

  updateForWindowResize() {
    if (this.enabled) {
      camera.left = innerWidth / -2;
      camera.right = innerWidth / 2;
      camera.top = innerHeight / 2;
      camera.bottom = innerHeight / -2;
      camera.updateProjectionMatrix();

      this.update();
    }
  }
}
