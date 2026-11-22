function glCanvas(canvas,options) {
  // const canvas = document.createElement("canvas");
  // canvas.id = id;
  // canvas.width = width; // Set width to 800 pixels
  // canvas.height = height; // Set height to 600 pixels

  document.body.appendChild(canvas);
  const glp = canvas.getContext("webgl2",options);
  if (!glp) {
    alert("Your browser does not support WebGL 2.");
    return;
  }
  console.log("WebGL2 context created successfully!");

  return glp;
}

async function glMakeXRCompatible(gl){
  await gl.makeXRCompatible();
}

function glScissor(gl, x, y, width, height) {
  gl.scissor(x, y, width, height);
}

function glViewport(gl, x, y, width, height){
  gl.viewport(x, y, width, height);
}

function glGetShaderPrecisionFormat(gl) {
  return ShaderPrecisionFormat();
}

function glGetExtension(gl,key) {
  return gl.getExtension(key);
}

function glGetParameter(gl,key) {
  return gl.getParameter(key);
}

function glGetString(gl,key) {
  return gl.getParameter(key);
}

function createTexture(gl) {
  return gl.createTexture();
}
function glCreateTexture(gl) {
  return gl.createTexture();
}
function glBindTexture(gl, type, texture) {
  gl.bindTexture(type, texture);
}

function glDrawElementsInstanced(gl, mode, count, type, offset, instanceCount) {
  gl.drawElementsInstanced(mode, count, type, offset, instanceCount);
}

function glActiveTexture(gl, v0) {
  gl.activeTexture(v0);
}

function glTexParameteri(gl, target, pname, param) {
  gl.texParameteri(target, pname, param);
}

function glTexImage2D(gl, 
  target, 
  level, 
  internalformat, 
  width, 
  height, 
  border, 
  format, 
  type, 
  pixels
) {    
  gl.texImage2D(target, level, internalformat, width, height, border, format, type, pixels);
}

function glTexImage2D_NOSIZE(gl,     
  target, 
  level, 
  internalformat, 
  format, 
  type, 
  pixels
) { 
  gl.texImage2D(target, level, internalformat, format, type, pixels);
}

function glTexImage3D(gl, target, level, internalformat, width, height, depth, border, format, type, pixels) {
  gl.texImage3D(target, level, internalformat, width, height, depth,border, format, type, pixels);
}

function glDepthFunc(gl, v0) {
  gl.depthFunc(v0);
}

function glDepthMask(gl, v0) {
  gl.depthMask(v0);
}

function glEnable(gl, v0) {
  gl.enable(v0);
}

function glDisable(gl, v0) {
  gl.disable(v0);
}

function glBlendEquation(gl, v0) {
  gl.blendEquation(v0);
}

function glUseProgram(gl, program) {
  gl.useProgram(program);
}

function glBlendFuncSeparate(gl, srcRGB, dstRGB, srcAlpha, dstAlpha) {
  gl.blendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
}

function glBlendFunc(gl, sfactor, dfactor){
  gl.blendFunc(sfactor, dfactor);
}

function glBlendEquationSeparate(gl, modeRGB, modeAlpha){
  gl.blendEquationSeparate(modeRGB, modeAlpha);
}

function glFrontFace(gl, mode) {
  gl.frontFace(mode);
}

function glCullFace(gl, mode) {
  gl.cullFace(mode);
}

function glLineWidth(gl, width) {
  gl.lineWidth(width);
}

function glPolygonOffset(gl, factor, units) {
  gl.polygonOffset(factor, units);
}

function glStencilMask(gl, mask) {
  gl.stencilMask(mask);
}

function glStencilFunc(gl, func, ref, mask){
  gl.stencilFunc(func, ref, mask);
}

function glStencilOp(gl, fail, zfail, zpass){
  gl.stencilOp(fail, zfail, zpass);
}

function glClearStencil(gl, s) {
  gl.clearStencil(s);
}

function glClearDepth(gl, depth) {
  gl.clearDepth(depth);
}

function glColorMask(gl, red, green, blue, alpha) {
  gl.colorMask(red, green, blue, alpha);
}

function glClearColor(gl, red, green, blue, alpha){
  gl.clearColor(red, green, blue, alpha);
}

function glCompressedTexImage2D(gl, target, level, internalformat, width, height, border, imageSize, data){
  gl.compressedTexImage2D(target, level, internalformat, width, height, border, imageSize, data);
}

function glGenerateMipmap(gl, target) {
  gl.generateMipmap(target);
}

function glDeleteTexture(gl, v0) {
  gl.deleteTexture(v0);
}

function glDeleteFramebuffer(gl, framebuffer) {
  gl.deleteFramebuffer(framebuffer);
}

function glDeleteRenderbuffer(gl, renderbuffer) {
  gl.deleteRenderbuffer(renderbuffer);
}

function glTexParameterf(gl, target, pname, param) {
  gl.texParameterf(target, pname, param);
}

function glPixelStorei(gl, pname, param) {
  gl.pixelStorei(pname, param);
}

function glGetContextAttributes(gl) {
  return gl.getContextAttributes();
}

function glGetProgramParameter(gl, program, pname) {
  return gl.getProgramParameter(program, pname);
}

function glGetActiveUniform(gl, v0, v1) {
    var temp = gl.getActiveUniform(v0, v1);
  return {
    "type": temp.type,
    "name": temp.name,
    "size": temp.size
  };
}

function glGetActiveAttrib(gl, v0, v1) {
    var temp =  gl.getActiveAttrib(v0, v1);
  return {
    "type": temp.type,
    "name": temp.name,
    "size": temp.size
  };
}

function glGetUniformLocation(gl, program, name) {
  return gl.getUniformLocation(program, name);
}

function glClear(gl, mask) {
  gl.clear(mask);
}

function glCreateBuffer(gl) {
  return gl.createBuffer();
}

function glBindBuffer(gl, target, buffer) {
  gl.bindBuffer(target, buffer);
}

function glBufferData(gl, target, data, usage) {
  gl.bufferData(target, data, usage);
}

function glVertexAttribPointer(gl, index, size, type, normalized, stride, offset) {
  gl.vertexAttribPointer(index, size, type, normalized, stride, offset);
}

function glDrawArrays(gl, mode, first, count) {
  gl.drawArrays(mode, first, count);
}

function glDrawArraysInstanced(gl, mode, first, count, instanceCount){
  gl.drawArraysInstanced(mode, first, count, instanceCount);
}

function glBindFramebuffer(gl, target, framebuffer){
  gl.bindFramebuffer(target, framebuffer);
}

function glCheckFramebufferStatus(gl, target) {
  return gl.checkFramebufferStatus(target);
}

function glFramebufferTexture2D(gl, target, attachment, textarget, texture, level){
  gl.framebufferTexture2D(target, attachment, textarget, texture, level);
}

function glFramebufferTextureLayer(gl, target, attachment, texture, level, layer){
  gl.glFramebufferTextureLayer(target, attachment, texture, level,layer);
}

function glReadPixels(gl, x, y, width, height, format, type, pixels) {
  gl.readPixels(x, y, width, height, format, type, pixels);
}

function glIsProgram(gl, program){
  return gl.isProgram(program) != 0;
}

function glCopyTexImage2D(gl, target, level, internalformat, x, y, width, height, border){
  gl.copyTexImage2D(
      target, level, internalformat, x, y, width, height, border);
}

function glTexSubImage2D(gl, target, level, xoffset, yoffset, width, height, format, type, pixels) {
  gl.texSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels);
}

function glCopyTexSubImage2D(gl, target, level, xoffset, yoffset, x, y, width, height) {
  gl.copyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
}

function glTexSubImage2D_NOSIZE(gl, target, level, xoffset, yoffset, format, type, pixels){
  gl.texSubImage2D(target, level, xoffset, yoffset, format, type, pixels);
}

function glTexSubImage3D(gl, 
  target,
  level,
  xoffset,
  yoffset,
  zoffset,
  width,
  height,
  depth,
  format,
  type,
  pixels
) {
  gl.texSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels);
}

function glCompressedTexSubImage2D(gl, target, level, xoffset, yoffset, width, height, format, pixels) {
  gl.compressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, pixels);
}

function glBindRenderbuffer(gl, target, framebuffer){
  gl.bindRenderbuffer(target, framebuffer);
}

function glRenderbufferStorageMultisample(gl, target, samples, internalformat, width, height){
  gl.renderbufferStorageMultisample(target, samples, internalformat, width, height);
}

function glRenderbufferStorage(gl, target, internalformat, width, height){
  gl.renderbufferStorage(target, internalformat, width, height);
}

function glFramebufferRenderbuffer(gl, target, attachment, renderbuffertarget, renderbuffer){
  gl.framebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer);
}

function glCreateRenderbuffer(gl) {
  return gl.createRenderbuffer();
}
function glGenRenderbuffers(gl, count, buffers) {
  for(i = 0; i < count; i++){
    buffers.add(gl.createRenderbuffer());
  }
}
function glCreateFramebuffer(gl) {
  return gl.createFramebuffer();
}
function glGenFramebuffers(gl, count, buffers) {
  for(i = 0; i < count; i++){
    buffers.add(gl.createFramebuffer());
  }
}
function glBlitFramebuffer(gl, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter){
  gl.blitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
}

function glBufferSubData(gl, target, dstByteOffset, srcData, srcOffset, length){
  gl.bufferSubData(target, dstByteOffset, srcData);
}

function glCreateVertexArray(gl) {
  return gl.createVertexArray();
}

function glCreateProgram(gl) {
  return gl.createProgram();
}

function glAttachShader(gl, program, shader) {
  gl.attachShader(program, shader);
}

function glBindAttribLocation(gl, program, index, name){
  gl.bindAttribLocation(program, index, name);
}

function glLinkProgram(gl, program) {
  gl.linkProgram(program);
}

function  glGetProgramInfoLog(gl, program) {
  return gl.getProgramInfoLog(program);
}

function  glGetShaderInfoLog(gl, shader){
  return gl.getShaderInfoLog(shader);
}

function glGetError(gl) {
  return gl.getError();
}

function glDeleteShader(gl, shader) {
  gl.deleteShader(shader);
}

function glDeleteProgram(gl, program) {
  gl.deleteProgram(program);
}

function glDeleteBuffer(gl, buffer) {
  gl.deleteBuffer(buffer);
}

function glBindVertexArray(gl, array) {
  gl.bindVertexArray(array);
}

function glDeleteVertexArray(gl, array) {
  gl.deleteVertexArray(array);
}

function glEnableVertexAttribArray(gl, index) {
  gl.enableVertexAttribArray(index);
}

function glDisableVertexAttribArray(gl, index) {
  gl.disableVertexAttribArray(index);
}

function glVertexAttribIPointer(gl, index, size, type, stride, pointer){
  gl.vertexAttribIPointer(index, size, type, stride, pointer);
}

function glVertexAttrib2fv(gl, index, values) {
  gl.vertexAttrib2fv(index, values);
}

function glVertexAttrib3fv(gl, index, values) {
  gl.vertexAttrib3fv(index, values);
}

function glVertexAttrib4fv(gl, index, values) {
  gl.vertexAttrib4fv(index, values);
}

function glVertexAttrib1fv(gl, index, values) {
  gl.vertexAttrib1fv(index, values);
}

function glDrawElements(gl, mode, count, type, offset) {
  gl.drawElements(mode, count, type, offset);
}

function glDrawBuffers(gl, buffers) {
  gl.drawBuffers(buffers);
}

function glCreateShader(gl, type) {
  return gl.createShader(type);
}

function glShaderSource(gl, shader, shaderSource) {
  gl.shaderSource(shader, shaderSource);
}

function glCompileShader(gl, shader) {
  gl.compileShader(shader);
}

function glGetShaderParameter(gl, shader, pname){
  return gl.getShaderParameter(shader, pname);
}

function glGetShaderSource(gl, shader) {
  return gl.getShaderSource(shader);
}

function glUniformMatrix4fv(gl, location, transpose, values) {
  gl.uniformMatrix4fv(location, transpose, values);
}

function glUniform1i(gl, location, x) {
  gl.uniform1i(location, x);
}

function glUniform3f(gl, location, x, y, z) {
  gl.uniform3f(location, x, y, z);
}

function glUniform4f(gl, location, x, y, z, w){
  gl.uniform4f(location, x, y, z,w);
}

function glUniform1fv(gl, location, v){
  gl.uniform1fv(location, v);
}

function glUniform2fv(gl, location, v){
  gl.uniform2fv(location, v);
}

function glUniform3fv(gl, location, v){
  gl.uniform3fv(location, v);
}

function glUniform1f(gl, location, x){
  gl.uniform1f(location, x);
}

function glUniformMatrix3fv(gl, location, transpose, values) {
  gl.uniformMatrix3fv(location, transpose, values);
}

function glGetAttribLocation(gl, program, name) {
  return gl.getAttribLocation(program, name);
}

function glUniform2f(gl, location, x, y){
  gl.uniform2f(location, x, y);
}

function glUniform1iv(gl, location, v){
  gl.uniform1iv(location, v);
}

function glUniform2iv(gl, location, v){
  gl.uniform2iv(location, v);
}

function glUniform3iv(gl, location, v){
  gl.uniform3iv(location, v);
}

function glUniform4iv(gl, location, v){
  gl.uniform4iv(location, v);
}

function glUniform4fv(gl, location, vectors) {
  gl.uniform4fv(location, vectors);
}

function glVertexAttribDivisor(gl, index, divisor){
  gl.vertexAttribDivisor(index, divisor);
}

function glFlush(gl) {
  gl.flush();
}

function glFinish(gl) {
  gl.finish();
}

function glTexStorage2D(gl, target, levels, internalformat, width, height){
  gl.texStorage2D(target, levels, internalformat, width, height);
}

function glTexStorage3D(gl, target, levels, internalformat, width, height, depth){
  gl.texStorage3D(target, levels, internalformat, width, height, depth);
}

function glCreateTransformFeedback(gl) {
  return gl.createTransformFeedback();
}
function glBindTransformFeedback(gl, target, id){
  gl.bindTransformFeedback(target, id);
}

function glTransformFeedbackVaryings(gl, program, count, varyings, bufferMode) {
  gl.transformFeedbackVaryings(program, varyings, bufferMode);
}

function glDeleteTransformFeedback(gl, transformFeedback) {
  gl.deleteTransformFeedback(transformFeedback);
}

function isTransformFeedback(gl, transformFeedback) {
  return gl.isTransformFeedback(transformFeedback);
}

function glBeginTransformFeedback(gl, primitiveMode) {
  gl.beginTransformFeedback(primitiveMode);
}

function glEndTransformFeedback(gl) {
  gl.endTransformFeedback();
}

function glPauseTransformFeedback(gl) {
  gl.pauseTransformFeedback();
}

function glResumeTransformFeedback(gl) {
  gl.resumeTransformFeedback();
}

function  glGetTransformFeedbackVarying(gl, program, index) {
    var temp = gl.getTransformFeedbackVarying(program, index);
  return {
    "type": temp.type,
    "name": temp.name,
    "size": temp.size
  };
}

function glInvalidateFramebuffer(gl, target, attachments){
  gl.invalidateFramebuffer(target, attachments);
}

function  readCurrentPixels(gl, x, y, width, height) {
  _len = width * height * 4;
  buffer = Uint8List(_len);
  gl.readPixels(x, y, width, height, WebGL.RGBA, WebGL.UNSIGNED_BYTE, buffer);
  return buffer;
}

function glDrawingBufferColorSpace(gl,colorSpace){
  gl.drawingBufferColorSpace = colorSpace;
}

function glUnpackColorSpace(gl,colorSpace){
  gl.unpackColorSpace = colorSpace;
}