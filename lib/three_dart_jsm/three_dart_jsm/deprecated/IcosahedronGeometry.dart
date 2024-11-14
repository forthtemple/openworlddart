part of jsm_deprecated;

class IcosahedronGeometry extends Geometry {
  String type = "IcosahedronGeometry";

  IcosahedronGeometry(num radius, int detail) : super() {
    this.parameters = {"radius": radius, "detail": detail};

    this.fromBufferGeometry(THREE.IcosahedronGeometry(radius, detail));
    this.mergeVertices();
  }
}
