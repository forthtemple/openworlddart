part of jsm_deprecated;

class ConvexGeometry extends Geometry {
  String type = "ConvexGeometry";

  ConvexGeometry(points) : super() {
    this.fromBufferGeometry(THREE.ConvexGeometry(points ?? []));
    this.mergeVertices();
  }
}
