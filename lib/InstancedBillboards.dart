// This code is to have less draw objects.
// For example rather than draw 1000 tree sprites individually, they are drawn as a single object
import 'package:openworld/openworld.dart' as OPENWORLD;
import 'package:three_js/three_js.dart' as THREE;

class InstancedBillboards {
  final THREE.InstancedMesh mesh;
  final THREE.Object3D _dummy = THREE.Object3D();
  int _nextIndex = 0;

  InstancedBillboards._(this.mesh);

  factory InstancedBillboards.create(THREE.Texture texture, int maxCount, THREE.Scene scene, {color}) {
    final geometry = THREE.PlaneGeometry(1, 1); // unit quad; instance scale drives actual size
    final material = THREE.MeshBasicMaterial.fromMap( {
      'map': texture,
      'transparent': true,
      'alphaTest': 0.5,   // match however your sprite grass/trees cut out transparency now
      'side': THREE.DoubleSide,
     // 'colorSpace':THREE.SRGBColorSpace
    });
    if (color!=null)
      material.color=color;
    material.map?.colorSpace=THREE.SRGBColorSpace;

    material.onBeforeCompile = (shader, renderer) {
      shader.vertexShader = shader.vertexShader.replaceFirst(
          '#include <project_vertex>',
          '''
        #ifdef USE_INSTANCING
          vec3 instancePosition = instanceMatrix[3].xyz;
          vec3 instanceScale = vec3(
            length(instanceMatrix[0].xyz),
            length(instanceMatrix[1].xyz),
            length(instanceMatrix[2].xyz)
          );
        #else
          vec3 instancePosition = vec3(0.0);
          vec3 instanceScale = vec3(1.0);
        #endif
        vec3 cameraRight = vec3(viewMatrix[0][0], viewMatrix[1][0], viewMatrix[2][0]);
        vec3 cameraUp    = vec3(viewMatrix[0][1], viewMatrix[1][1], viewMatrix[2][1]);
        vec3 billboardWorldPos = instancePosition
          + cameraRight * position.x * instanceScale.x
          - cameraUp    * position.y * instanceScale.y;
        vec4 mvPosition = viewMatrix * vec4(billboardWorldPos, 1.0);
        gl_Position = projectionMatrix * mvPosition;
        '''
      );
    };

    final mesh = THREE.InstancedMesh(geometry, material, maxCount);
    mesh.frustumCulled = false;
    scene.add(mesh);
    return InstancedBillboards._(mesh);
  }

  void reset() => _nextIndex = 0;

  void place(double x, double y, double z, {double width = 1.0, double height = 1.0, local=false}) {

    if (!local) {
      _dummy.position.setValues(0, 0, 0);
      OPENWORLD.Space.worldToLocalSurfaceObj(
          _dummy, x, y, z + height / 2.0, level: 0);
    } else {
      _dummy.position=THREE.Vector3( x,y,z);
    }
    _dummy.scale.setValues(width, height, 1.0);
    _dummy.updateMatrix();
    mesh.setMatrixAt(_nextIndex, _dummy.matrix);
    _nextIndex++;
  }

  void finish() {
    mesh.count = _nextIndex;
    mesh.instanceMatrix!.needsUpdate = true;
  }
}