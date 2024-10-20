part of jsm_helpers;

var _v1 = new Vector3();
var _v2 = new Vector3();
var _normalMatrix = new Matrix3();

class VertexNormalsHelper extends LineSegments {
  late Object3D object;
  late int size;

  VertexNormalsHelper.create(geometry, material) : super(geometry, material) {}

  factory VertexNormalsHelper(object, [size = 1, color = 0xff0000]) {
    var geometry = new BufferGeometry();

    var nNormals = object.geometry.attributes["normal"].count;
    var positions =
        new Float32BufferAttribute(Float32Array(nNormals * 2 * 3), 3, false);

    geometry.setAttribute('position', positions);

    var vnh = VertexNormalsHelper.create(
        geometry, new LineBasicMaterial({"color": color, "toneMapped": false}));

    vnh.object = object;
    vnh.size = size;
    vnh.type = 'VertexNormalsHelper';

    //

    vnh.matrixAutoUpdate = false;

    vnh.update();

    return vnh;
  }

  update() {
    this.object.updateMatrixWorld(true);

    _normalMatrix.getNormalMatrix(this.object.matrixWorld);

    var matrixWorld = this.object.matrixWorld;

    var position = this.geometry!.attributes["position"];

  
    BufferGeometry? objGeometry = this.object.geometry;

    if (objGeometry != null && objGeometry is BufferGeometry) {
      var objPos = objGeometry.attributes["position"];

      var objNorm = objGeometry.attributes["normal"];

      var idx = 0;

      // for simplicity, ignore index and drawcalls, and render every normal

      for (var j = 0, jl = objPos.count; j < jl; j++) {
        _v1.fromBufferAttribute(objPos, j)
            .applyMatrix4(matrixWorld);

        _v2.fromBufferAttribute(objNorm, j);

        _v2
            .applyMatrix3(_normalMatrix)
            .normalize()
            .multiplyScalar(this.size)
            .add(_v1);

        position.setXYZ(idx, _v1.x, _v1.y, _v1.z);

        idx = idx + 1;

        position.setXYZ(idx, _v2.x, _v2.y, _v2.z);

        idx = idx + 1;
      }
    }

    position.needsUpdate = true;
  }
}
