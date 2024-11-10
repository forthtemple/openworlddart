part of jsm_deprecated;

class PlaneGeometry extends Geometry {
  String type = "PlaneGeometry";

  PlaneGeometry(width, height, [widthSegments = 1, heightSegments = 1])
      : super() {
    this.parameters = {
      "width": width,
      "height": height,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments
    };

    this.fromBufferGeometry(
        THREE.PlaneGeometry(width, height, widthSegments, heightSegments));
    this.mergeVertices();
  }
}
