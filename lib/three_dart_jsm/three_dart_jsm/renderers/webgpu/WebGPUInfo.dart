part of three_webgpu;

class WebGPUInfo {
  late bool autoReset;
  late Map render;
  late Map memory;

  WebGPUInfo() {
    this.autoReset = true;

    this.render = {
      "frame": 0,
      "drawCalls": 0,
      "triangles": 0,
      "points": 0,
      "lines": 0
    };

    this.memory = {"geometries": 0, "textures": 0};
  }

  update(object, count, instanceCount) {
    this.render["drawCalls"]++;

    if (object is Mesh) {
      this.render["triangles"] += instanceCount * (count / 3);
    } else if (object is Points) {
      this.render["points"] += instanceCount * count;
    } else if (object is LineSegments) {
      this.render["lines"] += instanceCount * (count / 2);
    } else if (object is Line) {
      this.render["lines"] += instanceCount * (count - 1);
    } else {
      console.error('THREE.WebGPUInfo: Unknown object type.');
    }
  }

  reset() {
    this.render["frame"]++;
    this.render["drawCalls"] = 0;
    this.render["triangles"] = 0;
    this.render["points"] = 0;
    this.render["lines"] = 0;
  }

  dispose() {
    this.reset();

    this.render["frame"] = 0;

    this.memory["geometries"] = 0;
    this.memory["textures"] = 0;
  }
}
