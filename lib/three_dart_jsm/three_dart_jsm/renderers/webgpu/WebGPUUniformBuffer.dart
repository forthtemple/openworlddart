part of three_webgpu;

class WebGPUUniformBuffer extends WebGPUBinding {
  late int bytesPerElement;
  late int usage;
  dynamic buffer;
  GPUBuffer? bufferGPU;

  WebGPUUniformBuffer(name, [buffer]) : super(name) {
    this.bytesPerElement = Float32List.bytesPerElement;
    this.type = GPUBindingType.UniformBuffer;
    this.visibility = GPUShaderStage.Vertex | GPUShaderStage.Fragment;

    this.usage = GPUBufferUsage.Uniform | GPUBufferUsage.Storage | GPUBufferUsage.CopyDst;

    this.buffer = buffer;
    this.bufferGPU = null; // set by the renderer
  }

  getByteLength() {
    return getFloatLength(this.buffer.byteLength);
  }

  getBuffer() {
    return this.buffer;
  }

  update() {
    return true;
  }
}
