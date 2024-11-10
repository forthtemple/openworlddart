part of jsm_helpers;

// var _v1 = new Vector3();
// var _v2 = new Vector3();

class VertexTangentsHelper extends LineSegments {
  late Object3D object;
  late int size;

  VertexTangentsHelper.create(geometry, material) : super(geometry, material) {}

  factory VertexTangentsHelper(object, [size = 1, color = 0x00ffff]) {
    var nTangents = object.geometry.attributes["tangent"].count;
    var geometry = new BufferGeometry();

    var positions =
        new Float32BufferAttribute(Float32Array(nTangents * 2 * 3), 3);

    geometry.setAttribute('position', positions);

    var vth = VertexTangentsHelper.create(
        geometry, new LineBasicMaterial({"color": color, "toneMapped": false}));

    vth.object = object;
    vth.size = size;
    vth.type = 'VertexTangentsHelper';

    //

    vth.matrixAutoUpdate = false;

    vth.update();

    return vth;
  }

  update() {
    this.object.updateMatrixWorld(true);

    var matrixWorld = this.object.matrixWorld;

    var position = this.geometry!.attributes["position"];

    //

    var objGeometry = this.object.geometry;

    var objPos = objGeometry!.attributes["position"];

    var objTan = objGeometry.attributes["tangent"];

    var idx = 0;

    // for simplicity, ignore index and drawcalls, and render every tangent

    for (var j = 0, jl = objPos.count; j < jl; j++) {
      _v1
          .fromBufferAttribute(objPos, j)
          .applyMatrix4(matrixWorld);

      _v2.fromBufferAttribute(objTan, j);

      _v2.transformDirection(matrixWorld).multiplyScalar(this.size).add(_v1);

      position.setXYZ(idx, _v1.x, _v1.y, _v1.z);

      idx = idx + 1;

      position.setXYZ(idx, _v2.x, _v2.y, _v2.z);

      idx = idx + 1;
    }

    position.needsUpdate = true;
  }
}
