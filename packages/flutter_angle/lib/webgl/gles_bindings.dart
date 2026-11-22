import 'dart:js_interop';
import 'dart:typed_data';
import './gles_bindings_wasm.dart' as gles;
import '../shared/webgl.dart';
import '../shared/classes.dart';

class LibOpenGLES{
  late dynamic gl;
  LibOpenGLES(this.gl);

  void glScissor(int x, int y, int width, int height) {
    gles.glScissor(gl, x, y, width, height);
  }

  void glViewport(int x, int y, int width, int height){
    gles.glViewport(gl, x, y, width, height);
  }

  ShaderPrecisionFormat glGetShaderPrecisionFormat() {
    return ShaderPrecisionFormat();
  }

  dynamic getExtension(String key) {
    return gles.glGetExtension(gl, key);
  }

  dynamic getParameter(key) {
    return gles.glGetParameter(gl, key);
  }

  dynamic getString(String key) {
    return gles.glGetString(gl, key);
  }

  dynamic createTexture() {
    return gles.createTexture(gl);
  }

  void glBindTexture(int type, dynamic texture) {
    gles.glBindTexture(gl, type, texture);
  }

  void glDrawElementsInstanced(int mode, int count, int type, int offset, int instanceCount) {
    gles.glDrawElementsInstanced(gl, mode, count, type, offset, instanceCount);
  }

  void glActiveTexture(int v0) {
    gles.glActiveTexture(gl, v0);
  }

  void glTexParameteri(int target, int pname, int param) {
    gles.glTexParameteri(gl, target, pname, param);
  }

  void glTexImage2D(
    int target, 
    int level, 
    int internalformat, 
    int width, 
    int height, 
    int border, 
    int format, 
    int type, 
    TypedData? pixels
  ) {
    gles.glTexImage2D(gl, target, level, internalformat, width, height, border, format, type, pixels.jsify());
  }

  void glTexImage2D_NOSIZE(    
    int target, 
    int level, 
    int internalformat, 
    int border, 
    int format, 
    int type, 
    TypedData? pixels
  ) { 
    gles.glTexImage2D_NOSIZE(gl, target, level, internalformat, format, type, pixels.jsify());
  }

  void glTexImage3D(int target, int level, int internalformat, int width, int height, int depth, int border, int format, int type, TypedData? pixels) {
    gles.glTexImage3D(gl, target, level, internalformat, width, height, depth,border, format, type, pixels.jsify());
  }

  void glDepthFunc(int v0) {
    gles.glDepthFunc(gl, v0);
  }

  void glDepthMask(bool v0) {
    gles.glDepthMask(gl, v0);
  }

  void glEnable(int v0) {
    gles.glEnable(gl, v0);
  }

  void glDisable(int v0) {
    gles.glDisable(gl, v0);
  }

  void glBlendEquation(int v0) {
    gles.glBlendEquation(gl, v0);
  }

  void glUseProgram(dynamic program) {
    gles.glUseProgram(gl, program);
  }

  void glBlendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha) {
    gles.glBlendFuncSeparate(gl, srcRGB, dstRGB, srcAlpha, dstAlpha);
  }

  void glBlendFunc(int sfactor, int dfactor){
    gles.glBlendFunc(gl, sfactor, dfactor);
  }

  void glBlendEquationSeparate(int modeRGB, int modeAlpha){
    gles.glBlendEquationSeparate(gl, modeRGB, modeAlpha);
  }

  void glFrontFace(int mode) {
    gles.glFrontFace(gl, mode);
  }

  void glCullFace(int mode) {
    gles.glCullFace(gl, mode);
  }

  void glLineWidth(double width) {
    gles.glLineWidth(gl, width);
  }

  void glPolygonOffset(double factor, double units) {
    gles.glPolygonOffset(gl, factor, units);
  }

  void glStencilMask(int mask) {
    gles.glStencilMask(gl, mask);
  }

  void glStencilFunc(int func, int ref, int mask){
    gles.glStencilFunc(gl, func, ref, mask);
  }

  void glStencilOp(int fail, int zfail, int zpass){
    gles.glStencilOp(gl, fail, zfail, zpass);
  }

  void glClearStencil(int s) {
    gles.glClearStencil(gl, s);
  }

  void glClearDepth(double depth) {
    gles.glClearDepth(gl, depth);
  }

  void glColorMask(bool red, bool green, bool blue, bool alpha) {
    gles.glColorMask(gl, red, green, blue, alpha);
  }

  void glClearColor(double red, double green, double blue, double alpha){
    gles.glClearColor(gl, red, green, blue, alpha);
  }

  void glCompressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, TypedData? data){
    gles.glCompressedTexImage2D(gl, target, level, internalformat, width, height, border, data.jsify());
  }

  void glGenerateMipmap(int target) {
    gles.glGenerateMipmap(gl, target);
  }

  void glDeleteTexture(dynamic v0) {
    gles.glDeleteTexture(gl, v0);
  }

  void glDeleteFramebuffer(dynamic framebuffer) {
    gles.glDeleteFramebuffer(gl, framebuffer);
  }

  void deleteRenderbuffer(dynamic renderbuffer) {
    gles.glDeleteRenderbuffer(gl, renderbuffer);
  }

  void texParameterf(int target, int pname, double param) {
    gles.glTexParameterf(gl, target, pname, param);
  }

  void glPixelStorei(int pname, int param) {
    gles.glPixelStorei(gl, pname, param);
  }

  dynamic getContextAttributes() {
    return gles.glGetContextAttributes(gl);
  }

  dynamic getProgramParameter(dynamic program, int pname) {
    return gles.glGetProgramParameter(gl, program ,pname);
  }

  dynamic getActiveUniform(v0, v1) {
    return gles.glGetActiveUniform(gl, v0,v1);
  }

  dynamic getActiveAttrib(dynamic v0, int v1) {
    return gles.glGetActiveAttrib(gl, v0,v1);
  }

  dynamic glGetUniformLocation(dynamic program, String name) {
    return gles.glGetUniformLocation(gl, program, name);
  }

  void glClear(mask) {
    gles.glClear(gl, mask);
  }

  dynamic glCreateBuffer() {
    return gles.glCreateBuffer(gl);
  }

  void glBindBuffer(int target, dynamic buffer) {
    gles.glBindBuffer(gl, target, buffer);
  }

  void glBufferData(int target, TypedData data, int usage) {
    gles.glBufferData(gl, target, data.jsify(), usage);
  }

  void glVertexAttribPointer(int index, int size, int type, bool normalized, int stride, int offset) {
    gles.glVertexAttribPointer(gl, index, size, type, normalized, stride, offset);
  }

  void glDrawArrays(int mode, int first, int count) {
    gles.glDrawArrays(gl, mode, first, count);
  }

  void glDrawArraysInstanced(int mode, int first, int count, int instanceCount){
    gles.glDrawArraysInstanced(gl, mode, first, count, instanceCount);
  }

  void glBindFramebuffer(int target, dynamic framebuffer){
    gles.glBindFramebuffer(gl, target, framebuffer);
  }

  int glCheckFramebufferStatus(int target) {
    return gles.glCheckFramebufferStatus(gl, target);
  }

  void glFramebufferTexture2D(int target, int attachment, int textarget, dynamic texture, int level){
    gles.glFramebufferTexture2D(gl, target, attachment, textarget, texture, level);
  }

  void glReadPixels(int x, int y, int width, int height, int format, int type, TypedData? pixels) {
    gles.glReadPixels(gl, x, y, width, height, format, type, pixels.jsify());
  }

  bool glIsProgram(dynamic program){
    return gles.glIsProgram(gl, program);
  }

  void glCopyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border){
    gles.glCopyTexImage2D(gl, target, level, internalformat, x, y, width, height, border);
  }

  void glTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, int type, TypedData? pixels) {
    gles.glTexSubImage2D(gl, target, level, xoffset, yoffset, width, height, format, type, pixels.jsify());
  }

  void glTexSubImage2D_NOSIZE(int target, int level, int xoffset, int yoffset, int format, int type, TypedData? pixels){
    gles.glTexSubImage2D_NOSIZE(gl, target, level, xoffset, yoffset, format, type, pixels.jsify());
  }

  void glTexSubImage3D(
    int target,
    int level,
    int xoffset,
    int yoffset,
    int zoffset,
    int width,
    int height,
    int depth,
    int format,
    int type,
    TypedData? pixels
  ) {
    gles.glTexSubImage3D(gl, target, level, xoffset, yoffset, zoffset, width, height, depth, format, type, pixels.jsify());
  }

  void glCompressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, TypedData? pixels) {
    gles.glCompressedTexSubImage2D(gl, target, level, xoffset, yoffset, width, height, format, pixels.jsify());
  }

  void glBindRenderbuffer(int target, dynamic framebuffer){
    gles.glBindRenderbuffer(gl, target, framebuffer);
  }

  void glRenderbufferStorageMultisample(int target, int samples, int internalformat, int width, int height){
    gles.glRenderbufferStorageMultisample(gl, target, samples, internalformat, width, height);
  }

  void glRenderbufferStorage(int target, int internalformat, int width, int height){
    gles.glRenderbufferStorage(gl, target, internalformat, width, height);
  }

  void glFramebufferRenderbuffer(int target, int attachment, int renderbuffertarget, dynamic renderbuffer){
    gles.glFramebufferRenderbuffer(gl, target, attachment, renderbuffertarget, renderbuffer);
  }

  dynamic glCreateRenderbuffer() {
    return gles.glCreateRenderbuffer(gl);
  }
  void glGenRenderbuffers(int count, List buffers) {
    for(int i = 0; i < count; i++){
      buffers.add(gles.glCreateRenderbuffer(gl));
    }
  }
  dynamic glCreateFramebuffer() {
    return gles.glCreateFramebuffer(gl);
  }
  void glGenFramebuffers(int count, List buffers) {
    for(int i = 0; i < count; i++){
      buffers.add(gles.glCreateFramebuffer(gl));
    }
  }
  void glBlitFramebuffer(int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, int mask, int filter){
    gles.glBlitFramebuffer(gl, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
  }

  void glBufferSubData(int target, int dstByteOffset, TypedData srcData, int srcOffset, int length){
    gles.glBufferSubData(gl, target, dstByteOffset, srcData.jsify()!);
  }

  dynamic glCreateVertexArray() {
    return gles.glCreateVertexArray(gl);
  }

  dynamic glCreateProgram() {
    return gles.glCreateProgram(gl);
  }

  void glAttachShader(dynamic program, dynamic shader) {
    gles.glAttachShader(gl, program, shader);
  }

  void glBindAttribLocation(dynamic program, int index, String name){
    gles.glBindAttribLocation(gl, program, index, name);
  }

  void glLinkProgram(dynamic program, [bool checkForErrors = true]) {
    gles.glLinkProgram(gl, program);
  }

  String? getProgramInfoLog(dynamic program) {
    return gles.getProgramInfoLog(gl, program);
  }

  String? getShaderInfoLog(dynamic shader){
    return gles.getShaderInfoLog(gl, shader);
  }

  int glGetError() {
    return gles.glGetError(gl);
  }

  void glDeleteShader(dynamic shader) {
    gles.glDeleteShader(gl, shader);
  }

  void glDeleteProgram(dynamic program) {
    gles.glDeleteProgram(gl, program);
  }

  void glDeleteBuffer(dynamic buffer) {
    gles.glDeleteBuffer(gl, buffer);
  }

  void glBindVertexArray(dynamic array) {
    gles.glBindVertexArray(gl, array);
  }

  void glDeleteVertexArray(dynamic array) {
    gles.glDeleteVertexArray(gl, array);
  }

  void glEnableVertexAttribArray(int index) {
    gles.glEnableVertexAttribArray(gl, index);
  }

  void glDisableVertexAttribArray(int index) {
    gles.glDisableVertexAttribArray(gl, index);
  }

  void glVertexAttribIPointer(int index, int size, int type, int stride, int pointer){
    gles.glVertexAttribIPointer(gl, index, size, type, stride, pointer);
  }

  void glVertexAttrib2fv(int index, List<double> values) {
    gles.glVertexAttrib2fv(gl, index, values.jsify());
  }

  void glVertexAttrib3fv(int index, List<double> values) {
    gles.glVertexAttrib3fv(gl, index, values.jsify());
  }

  void glVertexAttrib4fv(int index, List<double> values) {
    gles.glVertexAttrib4fv(gl, index, values.jsify());
  }

  void glVertexAttrib1fv(int index, List<double> values) {
    gles.glVertexAttrib1fv(gl, index, values.jsify());
  }

  void glDrawElements(int mode, int count, int type, int offset) {
    gles.glDrawElements(gl, mode, count, type, offset);
  }

  void glDrawBuffers(List<int> buffers) {
    gles.glDrawBuffers(gl, buffers.jsify()!);
  }

  dynamic glCreateShader(int type) {
    return gles.glCreateShader(gl, type);
  }

  void glShaderSource(dynamic shader, String shaderSource) {
    gles.glShaderSource(gl, shader, shaderSource);
  }

  void glCompileShader(dynamic shader) {
    gles.glCompileShader(gl, shader);
  }

  bool glGetShaderParameter(dynamic shader, int pname){
    return gles.glGetShaderParameter(gl, shader, pname);
  }

  String? glGetShaderSource(dynamic shader) {
    return gles.glGetShaderSource(gl, shader);
  }

  void glUniformMatrix4fv(dynamic location, bool transpose, List<double> values) {
    gles.glUniformMatrix4fv(gl, location, transpose, values.jsify());
  }

  void glUniform1i(dynamic location, int x) {
    gles.glUniform1i(gl, location, x);
  }

  void glUniform3f(dynamic location, double x, double y, double z) {
    gles.glUniform3f(gl, location, x, y, z);
  }

  void glUniform4f(dynamic location, double x, double y, double z, double w){
    gles.glUniform4f(gl, location, x, y, z, w);
  }

  void glUniform1fv(dynamic location, List<double> v){
    gles.glUniform1fv(gl, location, v.jsify());
  }

  void glUniform2fv(dynamic location, List<double> v){
    gles.glUniform2fv(gl, location, v.jsify());
  }

  void glUniform3fv(dynamic location, List<double> v){
    gles.glUniform3fv(gl, location, v.jsify());
  }

  void glUniform1f(dynamic location, double x){
    gles.glUniform1f(gl, location, x);
  }

  void glUniformMatrix3fv(dynamic location, bool transpose, List<double> values) {
    gles.glUniformMatrix3fv(gl, location, transpose, values.jsify());
  }

  dynamic glGetAttribLocation(dynamic program, String name) {
    return gles.glGetAttribLocation(gl, program, name);
  }

  void glUniform2f(dynamic location, double x, double y){
    gles.glUniform2f(gl, location, x, y);
  }

  void glUniform1iv(dynamic location, List<int> v){
    gles.glUniform1iv(gl, location, v.jsify());
  }

  void glUniform2iv(dynamic location, List<int> v){
    gles.glUniform2iv(gl, location, v.jsify());
  }

  void glUniform3iv(dynamic location, List<int> v){
    gles.glUniform3iv(gl, location, v.jsify());
  }

  void glUniform4iv(dynamic location, List<int> v){
    gles.glUniform4iv(gl, location, v.jsify());
  }

  void glUniform4fv(dynamic location, List<double> vectors) {
    gles.glUniform4fv(gl, location, vectors.jsify());
  }

  void glVertexAttribDivisor(int index, int divisor){
    gles.glVertexAttribDivisor(gl, index, divisor);
  }

  void glFlush() {
    gles.glFlush(gl);
  }

  void glFinish() {
    gles.glFinish(gl);
  }

  void glTexStorage2D(int target, int levels, int internalformat, int width, int height){
    gles.glTexStorage2D(gl, target, levels, internalformat, width, height);
  }

  void glTexStorage3D(int target, int levels, int internalformat, int width, int height, int depth){
    gles.glTexStorage3D(gl, target, levels, internalformat, width, height, depth);
  }

  int glCreateTransformFeedback() {
    return gles.glCreateTransformFeedback(gl);
  }
  void glBindTransformFeedback(int target, dynamic id){
    gles.glBindTransformFeedback(gl, target, id);
  }

  void glTransformFeedbackVaryings(dynamic program, int count, List<String> varyings, int bufferMode) {
    gles.glTransformFeedbackVaryings(gl, program, varyings.jsify(), bufferMode);
  }

  void glDeleteTransformFeedback(dynamic transformFeedback) {
    gles.glDeleteTransformFeedback(gl, transformFeedback);
  }

  bool isTransformFeedback(dynamic transformFeedback) {
    return gles.isTransformFeedback(gl, transformFeedback);
  }

  void glBeginTransformFeedback(int primitiveMode) {
    gles.glBeginTransformFeedback(gl, primitiveMode);
  }

  void glEndTransformFeedback() {
    gles.glEndTransformFeedback(gl);
  }

  void glPauseTransformFeedback() {
    gles.glPauseTransformFeedback(gl);
  }

  void glResumeTransformFeedback() {
    gles.glResumeTransformFeedback(gl);
  }

  Map<String, dynamic>? glGetTransformFeedbackVarying(dynamic program, int index) {
    return gles.glGetTransformFeedbackVarying(gl, program, index).dartify() as Map<String, dynamic>?;
  }

  void glInvalidateFramebuffer(int target, List<int> attachments){
    gles.glInvalidateFramebuffer(gl, target, attachments.jsify());
  }

  Uint8List readCurrentPixels(int x, int y, int width, int height) {
    int _len = width * height * 4;
    var buffer = Uint8List(_len);
    gles.glReadPixels(gl, x, y, width, height, WebGL.RGBA, WebGL.UNSIGNED_BYTE, buffer.jsify());
    return buffer;
  }

  void glCopyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height){
    gles.glCopyTexSubImage2D(gl, target, level, xoffset, yoffset, x, y, width, height);
  }
}
