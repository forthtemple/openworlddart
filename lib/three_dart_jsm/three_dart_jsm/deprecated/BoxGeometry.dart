part of jsm_deprecated;

class BoxGeometry extends Geometry {
  String type = "BoxGeometry";

  BoxGeometry(width, height, depth,
      [widthSegments = 1, heightSegments = 1, depthSegments = 1])
      : super() {
    this.parameters = {
      "width": width,
      "height": height,
      "depth": depth,
      "widthSegments": widthSegments,
      "heightSegments": heightSegments,
      "depthSegments": depthSegments
    };

    this.fromBufferGeometry(THREE.BoxGeometry(
        width, height, depth, widthSegments, heightSegments, depthSegments));
    this.mergeVertices();
  }
}
