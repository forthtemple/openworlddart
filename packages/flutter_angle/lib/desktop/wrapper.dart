import 'dart:io';

import 'package:flutter_angle/native-array/index.dart';
import 'package:flutter_angle/shared/console.dart';

import 'bindings/gles_bindings.dart';
import 'dart:ffi';
import 'dart:async';
import 'dart:ui';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';
import 'bindings/index.dart';
import '../shared/webgl.dart';
import '../shared/classes.dart';


// JS "WebGL2RenderingContext")
class RenderingContext {
  final LibOpenGLES gl;
  final int width;
  final int height;
  final bool checkGlErrorOnEveryCall;

  RenderingContext.create(this.gl, this.width, this.height, [this.checkGlErrorOnEveryCall = false]);

  /// As allocating and freeing native memory is expensive and we need regularly
  /// buffers to receive values from FFI function we create a small set here that will
  /// be reused constantly
  /// 
  void checkError([String message = '']) {
    if(!checkGlErrorOnEveryCall) return;
    final glError = gl.glGetError();
    if (glError != WebGL.NO_ERROR) {
      final openGLException = OpenGLException('RenderingContext.$message', glError);
      angleConsole.warning(openGLException.toString());
    }
  }

  void startCheck(String type){
    if(!checkGlErrorOnEveryCall) return;
    angleConsole.info('Start: $type');
  }

  void beginTransformFeedback(int primitiveMode){
    startCheck('beginTransformFeedback');
    gl.glBeginTransformFeedback(primitiveMode);
    checkError('beginTransformFeedback');
  }

  int getUniformBlockIndex(Program program, String uniformBlockName){
    var sourceString = uniformBlockName.toNativeUtf8();
    var arrayPointer = Pointer<Int8>.fromAddress(sourceString.address);
    int i = gl.glGetUniformBlockIndex(program.id, arrayPointer);
    calloc.free(arrayPointer);
    calloc.free(sourceString);
    return i;
  }

  void uniformBlockBinding(Program program, int uniformBlockIndex,int uniformBlockBinding){
    gl.glUniformBlockBinding(program.id,uniformBlockIndex,uniformBlockBinding);
  }

  void bindTransformFeedback(int target, TransformFeedback feedback){
    startCheck('bindTransformFeedback');
    gl.glBindTransformFeedback(target, feedback.id);
    checkError('bindTransformFeedback');
  }

  void bindVertexArray(VertexArrayObject array){
    startCheck('bindVertexArray');
    gl.glBindVertexArray(array.id);
    checkError('bindVertexArray');
  }

  void blitFramebuffer(int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, int mask, int filter){
    startCheck('blitFramebuffer');
    gl.glBlitFramebuffer(srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
    checkError('blitFramebuffer');
  }

  void bufferSubData(int target, int dstByteOffset, NativeArray srcData){
    startCheck('bufferSubData');
    gl.glBufferSubData(target, dstByteOffset, srcData.lengthInBytes, srcData.data);
    checkError('bufferSubData');
  }

  TransformFeedback createTransformFeedback() {
    startCheck('createTransformFeedback');
    final vPointer = calloc<Uint32>();
    gl.glGenTransformFeedbacks(1, vPointer);
    int _v = vPointer.value;
    calloc.free(vPointer);
    return TransformFeedback(_v);
  }
  VertexArrayObject createVertexArray(){
    startCheck('createVertexArray');
    final v = calloc<Uint32>();
    gl.glGenVertexArrays(1, v);
    int _v = v.value;
    calloc.free(v);
    return VertexArrayObject(_v);
  }

  void deleteTransformFeedback(TransformFeedback feedback){
    startCheck('deleteTransformFeedback');
    final List<int> _texturesList = [feedback.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteTransformFeedbacks(1, ptr);
    calloc.free(ptr);
    checkError('deleteTransformFeedback');
  }

  void deleteVertexArray(VertexArrayObject array){
    startCheck('deleteVertexArray');
    final List<int> _texturesList = [array.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteVertexArrays(1, ptr);
    calloc.free(ptr);
    checkError('deleteVertexArray');
  }

  void drawArraysInstanced(int mode, int first, int count, int instanceCount){
    startCheck('drawArraysInstanced');
    gl.glDrawArraysInstanced(mode, first, count, instanceCount);
    checkError('drawArraysInstanced');
  }

  void drawBuffers(Uint32Array buffers){
    startCheck('drawBuffers');
    gl.glDrawBuffers(buffers.length, buffers.data);
  }

  void drawElementsInstanced(int mode, int count, int type, int offset, int instanceCount){
    startCheck('drawElementsInstanced');
    var indices = Pointer<Void>.fromAddress(offset);
    gl.glDrawElementsInstanced(mode, count, type, indices, instanceCount);
    checkError('drawElementsInstanced');
    //calloc.free(indices);
  }

  void endTransformFeedback(){
    startCheck('endTransformFeedback');
    gl.glEndTransformFeedback();
    checkError('endTransformFeedback');
  }

  ActiveInfo getTransformFeedbackVarying(Program program, int index) {
    startCheck('getTransformFeedbackVarying');
    int maxLen = 100;
    var length = calloc<Int32>();
    var size = calloc<Int32>();
    var type = calloc<Uint32>();
    var name = calloc<Int8>(maxLen);

    gl.glGetTransformFeedbackVarying(program.id, index, maxLen - 1, length, size, type, name);
    checkError('getTransformFeedbackVarying');
    int _type = type.value;
    String _name = name.cast<Utf8>().toDartString();
    int _size = size.value;

    calloc.free(type);
    calloc.free(name);
    calloc.free(size);
    calloc.free(length);

    return ActiveInfo(_type, _name, _size);
  }

  void invalidateFramebuffer(int target, List<int> attachments){
    startCheck('invalidateFramebuffer');
    int count = attachments.length;
    final valuePtr = calloc<Uint32>(count);
    valuePtr.asTypedList(count).setAll(0, attachments);
    gl.glInvalidateFramebuffer(target, count, valuePtr);
    calloc.free(valuePtr);
    checkError('invalidateFramebuffer'); 
  }

  bool isTransformFeedback(TransformFeedback feedback){
    startCheck('isTransformFeedback');
    return gl.glIsTransformFeedback(feedback.id) == 0?false:true;
  }

  void pauseTransformFeedback(){
    startCheck('pauseTransformFeedback');
    gl.glPauseTransformFeedback();
    checkError('pauseTransformFeedback'); 
  }

  void renderbufferStorageMultisample(int target, int samples, int internalformat, int width, int height){
    startCheck('renderbufferStorageMultisample');
    gl.glRenderbufferStorageMultisample(target, samples, internalformat, width, height);
    checkError('renderbufferStorageMultisample');
  }

  void resumeTransformFeedback(){
    startCheck('resumeTransformFeedback');
    gl.glResumeTransformFeedback();
    checkError('resumeTransformFeedback');
  }

  void texImage3D(int target, int level, int internalformat, int width, int height, int depth, int border, int format, int type, NativeArray? pixels) {
    startCheck('texImage3D');

    gl.glTexImage3D(target, level, internalformat, width, height, depth, border, format, type, pixels?.data ?? nullptr);
    checkError('texImage3D');
  }

  void texStorage2D(int target, int levels, int internalformat, int width, int height){
    startCheck('texStorage2D');
    gl.glTexStorage2D(target, levels, internalformat, width, height);
  }

  void texStorage3D(int target, int levels, int internalformat, int width, int height, int depth){
    startCheck('texStorage3D');
    gl.glTexStorage3D(target, levels, internalformat, width, height, depth);
  }

  // //JS ('texSubImage3D')
  void texSubImage3D(
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
    NativeArray? pixels
  ){
    startCheck('texSubImage3D');
    gl.glTexSubImage3D(target, level, xoffset, yoffset, zoffset, width, height, depth, format, type,pixels?.data ?? nullptr);
    checkError('texSubImage3D');
  }

  void transformFeedbackVaryings(Program program, int count, List<String> varyings, int bufferMode) {
    startCheck('transformFeedbackVaryings');
    final varyingsPtr = calloc<Pointer<Int8>>(varyings.length);
    int i = 0;
    for(final varying in varyings) {
      varyingsPtr[i] = varying.toNativeUtf8().cast<Int8>();
      i = i + 1;
    }
    gl.glTransformFeedbackVaryings(program.id, count, varyingsPtr, bufferMode);
    checkError('transformFeedbackVaryings');
    calloc.free(varyingsPtr);
  }

  void uniform1ui(UniformLocation? location, int v0){
    startCheck('uniform1ui');
    gl.glUniform1ui(location?.id  ?? nullptr.address, v0);
    checkError('uniform1ui');
  }

  void uniform1uiv(UniformLocation? location, Uint32Array v){
    startCheck('uniform1uiv');
    gl.glUniform1uiv(location?.id  ?? nullptr.address, v.length, v.data);
    checkError('uniform1uiv'); 
  }

  void uniform2ui(UniformLocation? location, int v0, int v1){
    startCheck('uniform2ui');
    gl.glUniform2ui(location?.id  ?? nullptr.address, v0, v1);
    checkError('uniform2ui');
  }

  void uniform2uiv(UniformLocation? location, Uint32Array v){
    startCheck('uniform2uiv');
    gl.glUniform2uiv(location?.id  ?? nullptr.address, v.length, v.data);
    checkError('uniform1uiv'); 
  }

  void uniform3ui(UniformLocation? location, int v0, int v1, int v2){
    startCheck('uniform3ui');
    gl.glUniform3ui(location?.id  ?? nullptr.address, v0, v1, v2);
    checkError('uniform3ui');
  }

  void uniform3uiv(UniformLocation? location, Uint32Array v){
    startCheck('uniform3uiv');
    gl.glUniform3uiv(location?.id  ?? nullptr.address, v.length, v.data);
    checkError('uniform1uiv'); 
  }

  void uniform4ui(UniformLocation? location, int v0, int v1, int v2, int v3){
    startCheck('uniform4ui');
    gl.glUniform4ui(location?.id  ?? nullptr.address, v0, v1, v2, v3);
    checkError('uniform4ui');
  }

  void uniform4uiv(UniformLocation? location, Uint32Array v){
    startCheck('uniform4uiv');
    gl.glUniform4uiv(location?.id  ?? nullptr.address, v.length, v.data);
    checkError('uniform1uiv'); 
  }

  void vertexAttribDivisor(int index, int divisor){
    startCheck('vertexAttribDivisor');
    gl.glVertexAttribDivisor(index, divisor);
    checkError('vertexAttribDivisor');
  }

  void vertexAttribIPointer(int index, int size, int type, int stride, int pointer){
    startCheck('vertexAttribIPointer');
    var _pointer = calloc<Int32>();
    _pointer.value = pointer;
    gl.glVertexAttribIPointer(index, size, type, stride, _pointer.cast<Void>());
    calloc.free(_pointer);
    checkError('vertexAttribIPointer');
  }

  void activeTexture(int texture) {
    startCheck('activeTexture');
    gl.glActiveTexture(texture);
    checkError('activeTexture');
  }

  void attachShader(Program program, WebGLShader shader) {
    startCheck('attachShader');
    gl.glAttachShader(program.id, shader.id);
    checkError('attachShader');
  }

  void bindAttribLocation(Program program, int index, String name){
    startCheck('bindAttribLocation');
    final locationName = name.toNativeUtf8();
    gl.glBindAttribLocation(program.id, index,locationName.cast());
    checkError('bindAttribLocation');
    calloc.free(locationName);
  }

  void clearBufferuiv(int buffer,int drawbuffer, int value){
    startCheck('clearBufferuiv');
    Pointer<Uint32> id = calloc<Uint32>(value);
    gl.glClearBufferuiv(buffer,drawbuffer,id);
    checkError('clearBufferuiv');
    calloc.free(id);
  }

  void clearBufferiv(int buffer,int drawbuffer, int value){
    startCheck('clearBufferiv');
    Pointer<Int32> id = calloc<Int32>(value);
    gl.glClearBufferiv(buffer,drawbuffer,id);
    checkError('clearBufferiv');
    calloc.free(id);
  }

  void bindBuffer(int target, Buffer? buffer) {
    startCheck('bindBuffer');
    gl.glBindBuffer(target, buffer?.id ?? 0);
    checkError('bindBuffer');
  }

  void bindBufferBase(int target,int index, Buffer? buffer){
    startCheck('bindBufferBase');
    gl.glBindBufferBase(target,index,buffer?.id ?? 0);
    checkError('bindBufferBase');
  }

  void bindFramebuffer(int target, Framebuffer? framebuffer){
    startCheck('bindFramebuffer');
    if(framebuffer != null){
      gl.glBindFramebuffer(target, framebuffer.id);
    }
    checkError('bindFramebuffer');
  }

  void bindRenderbuffer(int target, Renderbuffer? renderbuffer){
    startCheck('bindRenderbuffer');
    gl.glBindRenderbuffer(target, renderbuffer?.id ?? nullptr.address);
    checkError('bindRenderbuffer');
  }

  void bindTexture(int target, WebGLTexture? texture) {
    startCheck('bindTexture');
    if(texture != null){
      gl.glBindTexture(target, texture.id);
    }
    checkError('bindTexture');
  }

  void blendEquation(int mode){
    startCheck('blendEquation');
    gl.glBlendEquation(mode);
    checkError('blendEquation');
  }

  void blendEquationSeparate(int modeRGB, int modeAlpha){
    startCheck('blendEquationSeparate');
    gl.glBlendEquationSeparate(modeRGB, modeAlpha);
  }

  void blendFunc(int sfactor, int dfactor){
    startCheck('blendFunc');
    gl.glBlendFunc(sfactor, dfactor);
  }

  void blendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha){
    startCheck('blendFuncSeparate');
    gl.glBlendFuncSeparate(srcRGB, dstRGB, srcAlpha, dstAlpha);
    checkError('blendFuncSeparate');
  }

  /// Be careful which type of integer you really pass here. Unfortunately an UInt16List
  /// is viewed by the Dart type system just as List<int>, so we jave to specify the native type
  /// here in [nativeType]
  void bufferData(int target, dynamic data, int? usage) {
    startCheck('bufferData');
    if(data is int){
      var offSetPointer = Pointer<Void>.fromAddress(data);
      gl.glBufferData(target, data, offSetPointer.cast(), usage ?? 0);
    }
    else{
      gl.glBufferData(target, data.lengthInBytes, data.data, usage ?? 0);
    }
    
    checkError('bufferData');
  }

  int checkFramebufferStatus(int target){
    startCheck('checkFramebufferStatus');
    return gl.glCheckFramebufferStatus(target);
  }

  void clear(int mask) => gl.glClear(mask);

  void clearColor(double red, double green, double blue, double alpha) {
    startCheck('clearColor');
    gl.glClearColor(red, green, blue, alpha);
    checkError('clearColor');
  }

  void clearDepth(double depth){
    startCheck('clearDepth');
    gl.glClearDepthf(depth);
    checkError('clearDepth');
  }

  void clearStencil(int s){
    startCheck('clearStencil');
    gl.glClearStencil(s);
    checkError('clearStencil');
  }

  void colorMask(bool red, bool green, bool blue, bool alpha){
    startCheck('colorMask');
    gl.glColorMask(red?1:0, green?1:0, blue?1:0, alpha?1:0);
    checkError('colorMask');
  }


  void compileShader(WebGLShader shader, [bool checkForErrors = true]) {
    startCheck('compileShader');
    gl.glCompileShader(shader.id);

    if (checkForErrors) {
      final compiled = calloc<Int32>();
      gl.glGetShaderiv(shader.id, GL_COMPILE_STATUS, compiled);
      if (compiled.value == 0) {
        final infoLen = calloc<Int32>();

        gl.glGetShaderiv(shader.id, GL_INFO_LOG_LENGTH, infoLen);

        String message = '';
        if (infoLen.value > 1) {
          final infoLog = calloc<Int8>(infoLen.value);

          gl.glGetShaderInfoLog(shader.id, infoLen.value, nullptr, infoLog);
          message = "\nError compiling shader:\n${infoLog.cast<Utf8>()}";

          calloc.free(infoLog);
        }
        calloc.free(infoLen);
        throw OpenGLException(message, 0);
      }
      calloc.free(compiled);
    }
  }

  void compressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, NativeArray? pixels){
    startCheck('compressedTexImage2D');
    gl.glCompressedTexImage2D(target, level, internalformat, width, height, border, pixels?.lengthInBytes??0,pixels?.data?? nullptr);
    checkError('compressedTexImage2D');
  }

  void compressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format ,NativeArray? pixels){
    startCheck('compressedTexSubImage2D');
    gl.glCompressedTexSubImage2D(target, level, xoffset, yoffset, width, height, format, pixels?.lengthInBytes??0,pixels?.data?? nullptr);
    checkError('compressedTexSubImage2D');
  }

  void copyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border){
    startCheck('copyTexImage2D');
    gl.glCopyTexImage2D(target, level, internalformat, x, y, width, height, border);
    checkError('copyTexImage2D');
  }

  // void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height);
  void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height){
    startCheck('copyTexSubImage2D');
    gl.glCopyTexSubImage2D(target, level, xoffset, yoffset, x, y, width, height);
    checkError('copyTexSubImage2D');
  }

  void copyTexSubImage3D(int target, int level, int xoffset, int yoffset, int zoffset, int x, int y, int width, int height){
    startCheck('copyTexSubImage3D');
    gl.glCopyTexSubImage3D(target, level, xoffset, yoffset, zoffset, x, y, width, height);
    checkError('copyTexSubImage3D');
  }

  Buffer createBuffer() {
    startCheck('createBuffer');
    Pointer<Uint32> id = calloc<Uint32>();
    gl.glGenBuffers(1, id);
    checkError('createBuffer');
    int _v = id.value;
    calloc.free(id);
    return Buffer(_v);
  }

  Framebuffer createFramebuffer(){
    startCheck('createFramebuffer');
    Pointer<Uint32> id = calloc<Uint32>();
    gl.glGenFramebuffers(1, id);
    checkError('createFramebuffer');
    int _v = id.value;
    calloc.free(id);
    return Framebuffer(_v);
  }

  Program createProgram() {
    startCheck('createProgram');
    final program = gl.glCreateProgram();
    checkError('createProgram');
    return Program(program);
  }

  Renderbuffer createRenderbuffer(){
    startCheck('createRenderbuffer');
    final v = calloc<Uint32>();
    gl.glGenRenderbuffers(1, v);
    int _v = v.value;
    calloc.free(v);
    return Renderbuffer(_v);
  }

  WebGLShader createShader(int type) {
    startCheck('createShader');
    final shader = gl.glCreateShader(type);
    checkError('createShader');
    return WebGLShader(shader);
  }

  WebGLTexture createTexture() {
    startCheck('createTexture');
    Pointer<Uint32> vPointer = calloc<Uint32>();
    gl.glGenTextures(1, vPointer);
    checkError('createBuffer');
    int _v = vPointer.value;
    calloc.free(vPointer);
    return WebGLTexture(_v);
  }

  int getParameter(int key) {
    startCheck('getParameter');

    List<int> _intValues = [
      WebGL.MAX_TEXTURE_IMAGE_UNITS,
      WebGL.MAX_VERTEX_TEXTURE_IMAGE_UNITS,
      WebGL.MAX_TEXTURE_SIZE,
      WebGL.MAX_CUBE_MAP_TEXTURE_SIZE,
      WebGL.MAX_VERTEX_ATTRIBS,
      WebGL.MAX_VERTEX_UNIFORM_VECTORS,
      WebGL.MAX_VARYING_VECTORS,
      WebGL.MAX_FRAGMENT_UNIFORM_VECTORS,
      WebGL.MAX_SAMPLES,
      WebGL.MAX_COMBINED_TEXTURE_IMAGE_UNITS,
      WebGL.SCISSOR_BOX,
      WebGL.VIEWPORT,
      WebGL.MAX_TEXTURE_MAX_ANISOTROPY_EXT,
      WebGL.MAX_UNIFORM_BUFFER_BINDINGS
    ];

    if (_intValues.indexOf(key) >= 0) {
      final v = calloc<Int32>(4);
      gl.glGetIntegerv(key, v);
      int _v = v.value;
      calloc.free(v);
      return _v;
    } else {
      throw (" OpenGL getParameter key: ${key} is not support ");
    }
  }

  void cullFace(int mode){
    startCheck('cullFace');
    gl.glCullFace(mode);
    checkError('cullFace');
  }

  void deleteBuffer(Buffer buffer){
    startCheck('deleteBuffer');
    final List<int> _texturesList = [buffer.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteBuffers(1, ptr);
    calloc.free(ptr);
    checkError('deleteBuffer');
  }

  void deleteFramebuffer(Framebuffer? framebuffer){
    if(framebuffer == null) return;
    startCheck('deleteFramebuffer');
    final List<int> _texturesList = [framebuffer.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteFramebuffers(1, ptr);
    calloc.free(ptr);
    checkError('deleteFramebuffer');
  }

  void deleteProgram(Program program){
    startCheck('deleteProgram');
    gl.glDeleteProgram(program.id);
  }

  void deleteRenderbuffer(Renderbuffer renderbuffer){
    startCheck('deleteRenderbuffer');
    final List<int> _texturesList = [renderbuffer.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteRenderbuffers(1, ptr);
    calloc.free(ptr);
    checkError('deleteFramebuffer');
  }

  void deleteShader(WebGLShader shader){
    startCheck('deleteShader');
    gl.glDeleteShader(shader.id);
  }

  void deleteTexture(WebGLTexture texture){
    startCheck('deleteTexture');
    final List<int> _texturesList = [texture.id];
    final ptr = calloc<Uint32>(_texturesList.length);
    ptr.asTypedList(1).setAll(0, _texturesList);
    gl.glDeleteTextures(1, ptr);
    calloc.free(ptr);
    checkError('deleteTexture');
  }

  void depthFunc(int func){
    startCheck('depthFunc');
    gl.glDepthFunc(func);
    checkError('depthFunc');
  }

  void depthMask(bool flag){
    startCheck('depthMask');
    gl.glDepthMask(flag?1:0);
    checkError('depthMask');
  }

  void disable(int cap) {
    startCheck('disable');
    gl.glDisable(cap);
    checkError('disable');
  }

  void disableVertexAttribArray(int index){
    startCheck('disableVertexAttribArray');
    gl.glDisableVertexAttribArray(index);
    checkError('disableVertexAttribArray');
  }

  void drawArrays(int mode, int first, int count) {
    startCheck('drawArrays');
    gl.glDrawArrays(mode, first, count);
    checkError('drawArrays');
  }

  void drawElements(int mode, int count, int type, int offset) {
    startCheck('drawElements');
    var offSetPointer = Pointer<Void>.fromAddress(offset);
    gl.glDrawElements(mode, count, type, offSetPointer.cast());
    checkError('drawElements');
    //calloc.free(offSetPointer);
  }

  void enable(int cap) {
    startCheck('enable');
    gl.glEnable(cap);
    checkError('enable');
  }

  void enableVertexAttribArray(int index) {
    startCheck('enableVertexAttribArray');
    gl.glEnableVertexAttribArray(index);
    checkError('enableVertexAttribArray');
  }

  void finish(){
    startCheck('finish');
    gl.glFinish();
    checkError('finish');
  }

  void flush(){
    startCheck('flush');
    gl.glFlush();
    checkError('flush');
  }

  void framebufferRenderbuffer(int target, int attachment, int renderbuffertarget, Renderbuffer? renderbuffer){
    startCheck('framebufferRenderbuffer');
    gl.glFramebufferRenderbuffer(target, attachment, renderbuffertarget, renderbuffer?.id  ?? nullptr.address);
    checkError('framebufferRenderbuffer');
  }

  void framebufferTexture2D(int target, int attachment, int textarget, WebGLTexture? texture, int level){
    startCheck('framebufferTexture2D');
    gl.glFramebufferTexture2D(target, attachment, textarget, texture?.id ?? 0, level);
    checkError('framebufferTexture2D');
  }

  void frontFace(int mode){
    startCheck('frontFace');
    gl.glFrontFace(mode);
    checkError('frontFace');
  }

  void generateMipmap(int target) {
    startCheck('generateMipmap');
    gl.glGenerateMipmap(target);
    checkError('generateMipmap');
  }

  ActiveInfo getActiveAttrib(Program v0, int v1) {
    startCheck('getActiveAttrib');
    var length = calloc<Int32>();
    var size = calloc<Int32>();
    var type = calloc<Uint32>();
    var name = calloc<Int8>(100);

    gl.glGetActiveAttrib(v0.id, v1, 99, length, size, type, name);
    checkError('getActiveAttrib');

    int _type = type.value;
    Pointer<Utf8> temp = name.cast<Utf8>();
    String _name = temp == nullptr?'unnamed':temp.toDartString();
    int _size = size.value;

    calloc.free(type);
    calloc.free(name);
    calloc.free(size);
    calloc.free(length);

    return ActiveInfo(_type, _name, _size);
  }

  ActiveInfo getActiveUniform(Program v0, int v1) {
    startCheck('getActiveUniform');
    var length = calloc<Int32>();
    var size = calloc<Int32>();
    var type = calloc<Uint32>();
    var name = calloc<Int8>(100);

    gl.glGetActiveUniform(v0.id, v1, 99, length, size, type, name);
    checkError('getActiveUniform');

    int _type = type.value;
    Pointer<Utf8> temp = name.cast<Utf8>();
    String _name = temp == nullptr?'unnamed':temp.toDartString();
    int _size = size.value;

    calloc.free(type);
    calloc.free(name);
    calloc.free(size);
    calloc.free(length);

    return ActiveInfo(_type, _name, _size);
  }

  UniformLocation getAttribLocation(Program program, String name) {
    startCheck('getAttribLocation');
    final locationName = name.toNativeUtf8();
    final location = gl.glGetAttribLocation(program.id, locationName.cast());
    checkError('getAttribLocation');
    calloc.free(locationName);
    return UniformLocation(location);
  }

  dynamic getContextAttributes() {
    startCheck('getContextAttributes');
    return null;
  }

  int getError(){
    startCheck('getError');
    return gl.glGetError();
  }

  Object? getExtension(String key) {
    startCheck('getExtension');
    if (Platform.isMacOS) {
      return getExtensionMacos(key);
    }
    Pointer<Uint8> _v = gl.glGetString(WebGL.EXTENSIONS);
    checkError('getExtension');
    String _vstr = _v == nullptr?'unnamed':_v.cast<Utf8>().toDartString();
    List<String> _extensions = _vstr.split(" ");
    //calloc.free(_v);
    return _extensions;
  }

  List<String> getExtensionMacos(String key) {
    startCheck('getExtensionMacos');
    List<String> _extensions = [];
    var nExtension = getIntegerv(33309);
    for (int i = 0; i < nExtension; i++) {
      _extensions.add(getStringi(GL_EXTENSIONS, i));
    }

    return _extensions;
  }

  String getStringi(int key, int index) {
    startCheck('getStringi');
    Pointer<Uint8> _v = gl.glGetStringi(key, index);
    checkError('getStringi');
    String str = _v == nullptr?'unnamed':_v.cast<Utf8>().toDartString();
    //calloc.free(_v);
    return str;
  }

  int getIntegerv(int v0) {
    startCheck('getIntegerv');
    Pointer<Int32> ptr = calloc<Int32>();
    gl.glGetIntegerv(v0, ptr);
    checkError('getIntegerv');
    int _v = ptr.value;
    calloc.free(ptr);

    return _v;
  }

  String? getProgramInfoLog(Program program){
    startCheck('getProgramInfoLog');
    var infoLen = calloc<Int32>();

    gl.glGetProgramiv(program.id, 35716, infoLen);

    int _len = infoLen.value;
    calloc.free(infoLen);

    String message = '';

    if (_len > 0) {
      final infoLog = calloc<Int8>(_len);
      gl.glGetProgramInfoLog(program.id, _len, nullptr, infoLog);
      checkError('getProgramInfoLog');
      message = "\nError compiling shader:\n${infoLog.cast<Utf8>()}";
      calloc.free(infoLog);
      return message;
    } 

    return null;
  }

  WebGLParameter getProgramParameter(Program program, int pname) {
    startCheck('getProgramParameter');
    final status = calloc<Int32>();
    gl.glGetProgramiv(program.id, pname, status);
    final _v = status.value;
    calloc.free(status);
    checkError('getProgramParameter');
    return WebGLParameter(_v);
  }


  String? getShaderInfoLog(WebGLShader shader){
    startCheck('getShaderInfoLog');
    final infoLen = calloc<Int32>();
    gl.glGetShaderiv(shader.id, 35716, infoLen);

    int _len = infoLen.value;
    calloc.free(infoLen);

    String message = '';
    if (_len > 1) {
      final infoLog = calloc<Int8>(_len);

      gl.glGetShaderInfoLog(shader.id, _len, nullptr, infoLog);
      checkError('getShaderInfoLog');
      message = "\nError compiling shader:\n${infoLog.cast<Utf8>()}";
      calloc.free(infoLog);
      return message;
    }
    return null;
  }

  bool getShaderParameter(WebGLShader shader, int pname){
    startCheck('getShaderParameter');
    var _pointer = calloc<Int32>();
    gl.glGetShaderiv(shader.id, pname, _pointer);
    checkError('getShaderParameter');
    final _v = _pointer.value;
    calloc.free(_pointer);
    return _v == 0?false:true;
  }
  void framebufferTextureLayer(int target,int attachment,WebGLTexture? texture,int level,int layer){
    startCheck('framebufferTextureLayer');
    gl.glFramebufferTextureLayer(target, attachment, texture?.id, level, layer);
    checkError('framebufferTextureLayer');
  }

  ShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype){
    startCheck('getShaderPrecisionFormat');
    return ShaderPrecisionFormat();
  }

  String? getShaderSource(int shader){
    startCheck('getShaderSource');
    // var sourceString = shaderSource.toNativeUtf8();
    // var arrayPointer = calloc<Int32>();
    // arrayPointer.value = Pointer.fromAddress(sourceString.address);
    // String temp = gl.glGetShaderSource(shader, 1, arrayPointer, nullptr);
    // calloc.free(arrayPointer);
    // calloc.free(sourceString);
    return null;
  }

  UniformLocation getUniformLocation(Program program, String name) {
    startCheck('getUniformLocation');
    final locationName = name.toNativeUtf8();
    final location = gl.glGetUniformLocation(program.id, locationName.cast());
    checkError('getProgramParameter');
    calloc.free(locationName);
    return UniformLocation(location);
  }

  bool isProgram(Program program){
    startCheck('isProgram');
    bool temp = gl.glIsProgram(program.id) != 0;
    checkError('isProgram');
    return temp;
  }

  void lineWidth(double width){
    startCheck('lineWidth');
    gl.glLineWidth(width);
    checkError('lineWidth');
  }

  void linkProgram(Program program, [bool checkForErrors = true]) {
    startCheck('linkProgram');
    gl.glLinkProgram(program.id);
    if (checkForErrors) {
      final linked = calloc<Int32>();
      gl.glGetProgramiv(program.id, GL_LINK_STATUS, linked);
      if (linked.value == 0) {
        final infoLen = calloc<Int32>();

        gl.glGetProgramiv(program.id, GL_INFO_LOG_LENGTH, infoLen);

        String message = '';
        if (infoLen.value > 1) {
          final infoLog = calloc<Int8>(infoLen.value);

          gl.glGetProgramInfoLog(program.id, infoLen.value, nullptr, infoLog);
          message = "\nError linking program:\n${infoLog.cast<Utf8>()}";

          calloc.free(infoLog);
        }
        calloc.free(infoLen);
        throw OpenGLException(message, 0);
      }
      calloc.free(linked);
    }
  }

  void pixelStorei(int pname, int param) {
    startCheck('pixelStorei');
    gl.glPixelStorei(pname, param);
    checkError('pixelStorei');
  }

  void polygonOffset(double factor, double units){
    startCheck('polygonOffset');
    gl.glPolygonOffset(factor, units);
    checkError('polygonOffset');
  }

  void renderbufferStorage(int target, int internalformat, int width, int height){
    startCheck('renderbufferStorage');
    gl.glRenderbufferStorage(target, internalformat, width, height);
    checkError('renderbufferStorage');
  }

  void scissor(int x, int y, int width, int height){
    startCheck('scissor');
    gl.glScissor(x, y, width, height);
    checkError('scissor');
  }

  void shaderSource(WebGLShader shader, String shaderSource) {
    startCheck('shaderSource');
    var sourceString = shaderSource.toNativeUtf8();
    var arrayPointer = calloc<Pointer<Int8>>();
    arrayPointer.value = Pointer.fromAddress(sourceString.address);
    gl.glShaderSource(shader.id, 1, arrayPointer, nullptr);
    calloc.free(arrayPointer);
    calloc.free(sourceString);
    checkError('shaderSource');
  }

  void stencilFunc(int func, int ref, int mask){
    startCheck('stencilFunc');
    gl.glStencilFunc(func, ref, mask);
  }

  void stencilMask(int mask){
    startCheck('stencilMask');
    gl.glStencilMask(mask);
    checkError('stencilMask');
  }

  void stencilOp(int fail, int zfail, int zpass){
    startCheck('stencilOp');
    gl.glStencilOp(fail, zfail, zpass);
    checkError('stencilOp');
  }

  void texImage2D(
    int target, 
    int level, 
    int internalformat, 
    int width, 
    int height, 
    int border, 
    int format, 
    int type, 
    NativeArray? pixels
  ) {
    startCheck('texImage2D');
    gl.glTexImage2D(target, level, internalformat, width, height, border, format, type,pixels?.data?? nullptr);
    checkError('texImage2D');
  }

  void texImage2D_NOSIZE(
    int target, 
    int level, 
    int internalformat, 
    int format, 
    int type, 
    NativeArray? pixels
  ) {
    texImage2D(target, level, internalformat, 0, 0, 0, format, type, pixels);
  }

  Future<void> texImage2DfromImage(
    int target,
    Image image, {
    int level = 0,
    int internalformat = WebGL.RGBA,
    int format = WebGL.RGBA,
    int type = WebGL.UNSIGNED_BYTE,
  }) async {
    Uint8Array submit = Uint8Array.fromList((await image.toByteData())!.buffer.asUint8List());
    texImage2D(target, level, internalformat, image.width, image.height, 0, format, type, submit);
    submit.dispose();
  }

  Future<void> texImage2DfromAsset(
    int target,
    String assetPath, {
    int level = 0,
    int internalformat = WebGL.RGBA32UI,
    int format = WebGL.RGBA,
    int type = WebGL.UNSIGNED_INT,
  }) async {
    final image = await loadImageFromAsset(assetPath);
    Uint8Array submit = Uint8Array.fromList((await image.toByteData())!.buffer.asUint8List());
    texImage2D(target, level, internalformat, image.width, image.height, 0, format, type, submit);
    submit.dispose();
  }

  Future<Image> loadImageFromAsset(String assetPath) async {
    startCheck('loadImageFromAsset');
    final bytes = await rootBundle.load(assetPath);
    final loadingCompleter = Completer<Image>();
    decodeImageFromList(bytes.buffer.asUint8List(), (image) {
      loadingCompleter.complete(image);
    });
    return loadingCompleter.future;
  }

  void texParameterf(int target, int pname, double param) {
    startCheck('texParameterf');
    gl.glTexParameterf(target, pname, param);
    checkError('texParameterf');
  }

  void texParameteri(int target, int pname, int param) {
    startCheck('texParameteri');
    gl.glTexParameteri(target, pname, param);
    checkError('texParameteri');
  }

  // //JS ('texSubImage2D')
  void texSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, int type, NativeArray? pixels){
    startCheck('texSubImage2D');
    gl.glTexSubImage2D(target, level, xoffset, yoffset, width, height, format, type, pixels?.data ?? nullptr);
    checkError('texImage2D');
  }

  void texSubImage2D_NOSIZE(int target, int level, int xoffset, int yoffset, int format, int type, NativeArray? pixels){
    startCheck('texSubImage2D_NOSIZE');
    texSubImage2D(target, level, xoffset, yoffset, 0, 0, format, type, pixels);
  }

  void uniform1f(UniformLocation location, double x){
    startCheck('uniform1f');
    gl.glUniform1f(location.id, x);
    checkError('uniform1f');
  }

  void uniform1fv(UniformLocation location, List<double> v){
    startCheck('uniform1fv');
    var arrayPointer = _floatListToArrayPointer(v);
    gl.glUniform1fv(location.id, v.length, arrayPointer);
    checkError('uniform1fv');
    calloc.free(arrayPointer);
  }

  void uniform1i(UniformLocation location, int x) {
    startCheck('uniform1i');
    gl.glUniform1i(location.id, x);
    checkError('uniform1i');
  }

  void uniform1iv(UniformLocation location, List<int> v){
    int count = v.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, v);
    gl.glUniform1iv(location.id, count, valuePtr);
    calloc.free(valuePtr);
    checkError('uniform1iv'); 
  }

  void uniform2f(UniformLocation location, double x, double y){
    startCheck('uniform2f');
    gl.glUniform2f(location.id, x, y);
    checkError('uniform2f'); 
  }

  void uniform2fv(UniformLocation location, List<double> v){
    startCheck('uniform2fv');
    var arrayPointer = _floatListToArrayPointer(v);
    gl.glUniform2fv(location.id, v.length ~/ 2, arrayPointer);
    checkError('uniform2fv');
    calloc.free(arrayPointer);
  }

  void uniform2i(UniformLocation location, int x, int y){
    gl.glUniform2i(location.id, x, y);
    checkError('uniform2iv'); 
  }

  void uniform2iv(UniformLocation location, List<int> v){
    int count = v.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, v);
    gl.glUniform2iv(location.id, count ~/ 2, valuePtr);
    calloc.free(valuePtr);
    checkError('uniform2iv'); 
  }

  void uniform3f(UniformLocation location, double x, double y, double z) {
    startCheck('uniform3f');
    gl.glUniform3f(location.id, x, y, z);
    checkError('uniform3f');
  }

  void uniform3fv(UniformLocation location, List<double> vectors) {
    startCheck('uniform3fv');
    var arrayPointer = _floatListToArrayPointer(vectors);
    gl.glUniform3fv(location.id, vectors.length ~/ 3, arrayPointer);
    checkError('uniform3fv');
    calloc.free(arrayPointer);
  }

  void uniform3iv(UniformLocation location, List<int> v){
    int count = v.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, v);
    gl.glUniform3iv(location.id, count ~/ 3, valuePtr);
    calloc.free(valuePtr);
    checkError('uniform3iv'); 
  }

  void uniform4f(UniformLocation location, double x, double y, double z, double w){
    startCheck('uniform4f');
    gl.glUniform4f(location.id, x, y, z,w);
    checkError('uniform4f');
  }

  void uniform4fv(UniformLocation location, List<double> vectors) {
    startCheck('uniform4fv');
    var arrayPointer = _floatListToArrayPointer(vectors);
    gl.glUniform4fv(location.id, vectors.length ~/ 4, arrayPointer);
    checkError('uniform4fv');
    calloc.free(arrayPointer);
  }

   void uniform4iv(UniformLocation location, List<int> v){
    int count = v.length;
    final valuePtr = calloc<Int32>(count);
    valuePtr.asTypedList(count).setAll(0, v);
    gl.glUniform4iv(location.id, count ~/ 4, valuePtr);
    calloc.free(valuePtr);
    checkError('uniform4iv'); 
  }

  void uniformMatrix2fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck('uniformMatrix2fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glUniformMatrix2fv(location.id, values.length ~/ 4, transpose ? 1 : 0, arrayPointer);
    checkError('uniformMatrix2fv');
    calloc.free(arrayPointer);
  }

  void uniformMatrix3fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck('uniformMatrix3fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glUniformMatrix3fv(location.id, values.length ~/ 9, transpose ? 1 : 0, arrayPointer);
    checkError('uniformMatrix3fv');
    calloc.free(arrayPointer);
  }

  /// be careful, data always has a length that is a multiple of 16
  void uniformMatrix4fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck('uniformMatrix4fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glUniformMatrix4fv(location.id, values.length ~/ 16, transpose ? 1 : 0, arrayPointer);
    checkError('uniformMatrix4fv');
    calloc.free(arrayPointer);
  }

  void useProgram(Program? program) {
    startCheck('useProgram');
    gl.glUseProgram(program?.id  ?? nullptr.address);
    checkError('useProgram');
  }

  void vertexAttrib1fv(int index, List<double> values){
    startCheck('vertexAttrib1fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glVertexAttrib1fv(index, arrayPointer);
    checkError('vertexAttrib2fv');
    calloc.free(arrayPointer);
  }

  void vertexAttrib2fv(int index, List<double> values){
    startCheck('vertexAttrib2fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glVertexAttrib2fv(index, arrayPointer);
    checkError('vertexAttrib2fv');
    calloc.free(arrayPointer);
  }

  void vertexAttrib3fv(int index, List<double> values){
    startCheck('vertexAttrib3fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glVertexAttrib3fv(index, arrayPointer);
    checkError('vertexAttrib3fv');
    calloc.free(arrayPointer);
  }

  void vertexAttrib4fv(int index, List<double> values){
    startCheck('vertexAttrib4fv');
    var arrayPointer = _floatListToArrayPointer(values);
    gl.glVertexAttrib4fv(index, arrayPointer);
    checkError('vertexAttrib4fv');
    calloc.free(arrayPointer);
  }

  void compressedTexSubImage3D(
    int target,
    int level,
    int xoffset,
    int yoffset,
    int zoffset,
    int width,
    int height,
    int depth,
    int format,
    NativeArray? pixels,
  ){
    startCheck('compressedTexSubImage3D');
    gl.glCompressedTexSubImage3D(target,level,xoffset,yoffset,zoffset,width,height,depth,format,pixels?.lengthInBytes??0,pixels?.data?? nullptr);
    checkError('compressedTexSubImage3D');
  }

  void compressedTexImage3D(
    int target,
    int level,
    int internalformat,
    int width,
    int height,
    int depth,
    int border,
    NativeArray? pixels,
  ){
    startCheck('compressedTexImage3D');
    gl.glCompressedTexImage3D(target,level,internalformat,width,height,depth,border,pixels?.lengthInBytes??0,pixels?.data?? nullptr);
    checkError('compressedTexImage3D');
  }

  void vertexAttribPointer(int index, int size, int type, bool normalized, int stride, int offset) {
    startCheck('vertexAttribPointer');
    Pointer<Void> offsetPointer = Pointer<Void>.fromAddress(offset);
    using((Arena arena) {
      gl.glVertexAttribPointer(index, size, type, normalized ? 1 : 0, stride, offsetPointer);
    });
    checkError('vertexAttribPointer');
    //calloc.free(offsetPointer);
  }

  void viewport(int x, int y, int width, int height) {
    startCheck('viewport');
    gl.glViewport(x, y, width, height);
    checkError('viewPort');
  }

  void readPixels(int x, int y, int width, int height, int format, int type, NativeArray? pixels) {
    startCheck('readPixels');
    gl.glReadPixels(x, y, width, height, format, type,pixels?.data ?? nullptr);
    checkError('readPixels');
  }

  Pointer<Float> _floatListToArrayPointer(List<double> list) {
    final ptr = calloc<Float>(list.length);
    ptr.asTypedList(list.length).setAll(0, list);
    return ptr;
  }

  Future<void> makeXRCompatible() async{
    throw('Web Only!');
  }

  set drawingBufferColorSpace(String cspace) => {
    gl.glEnable(GL_FRAMEBUFFER_SRGB_EXT)
  };
  set unpackColorSpace(String cspace) => {
    gl.glEnable(GL_FRAMEBUFFER_SRGB_EXT)
  };
}