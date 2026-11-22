import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_angle/native-array/index.dart';
import 'package:flutter_angle/shared/console.dart';
import 'package:web/web.dart' as html;
import '../shared/webgl.dart';
import 'gles_bindings_wasm.dart';
import '../shared/classes.dart';
import 'dart:async';
import 'dart:ui';
import 'gles_bindings.dart';

class RenderingContext{
  final LibOpenGLES gl;
  dynamic _gl;
  final int width;
  final int height;
  final bool checkGlErrorOnEveryCall;

  RenderingContext.create(this.gl, this.width, this.height,[this.checkGlErrorOnEveryCall = false]){
    _gl = gl.gl;
  }

  void checkError([String message = '']) {
    if(!checkGlErrorOnEveryCall) return;
    final glError = glGetError(_gl, );
    if (glError != WebGL.NO_ERROR) {
      final openGLException = OpenGLException('RenderingContext.$message', glError);
      angleConsole.warning(openGLException.toString());
    }
  }
  void startCheck(String type){
    if(!checkGlErrorOnEveryCall) return;
    angleConsole.info('Start: $type');
  }

  static dynamic createCanvas(JSObject _divId, [JSAny? options]){
    return glCanvas(_divId,options);
  }

  void scissor(int x, int y, int width, int height){
    startCheck("scissor");
    glScissor(_gl, x, y, width, height);
    checkError('scissor');
  }

  void viewport(int x, int y, int width, int height) {
    startCheck("viewport");
    glViewport(_gl, x, y, width, height);
    checkError('viewport');
  }

  ShaderPrecisionFormat getShaderPrecisionFormat(int shadertype, int precisiontype) {
    startCheck("ShaderPrecisionFormat");
    return ShaderPrecisionFormat();
  }

  dynamic getExtension(String key) {
    startCheck("getExtension");
    return glGetExtension(_gl, key).dartify();
  }
  int getUniformBlockIndex(Program program, String uniformBlockName){
    startCheck("getUniformBlockIndex");
    return glGetUniformBlockIndex(_gl, program.id, uniformBlockName);
  }

  void uniformBlockBinding(Program program, int uniformBlockIndex,int uniformBlockBinding){
    startCheck("uniformBlockBinding");
    glUniformBlockBinding(_gl, program.id,uniformBlockIndex,uniformBlockBinding);
  }
  // getParameter(key) {
  //   glGetParameter(_gl, key);
  // }

  // getString(String key) {
  //   glGetParameter(_gl, key);
  // }

  WebGLTexture createTexture() {
    startCheck("createTexture");
    return WebGLTexture(glCreateTexture(_gl));
  }

  void bindTexture(int target, WebGLTexture? texture) {
    startCheck("bindTexture");
    if(texture == null) return;
    glBindTexture(_gl, target, texture.id);
    checkError('bindTexture');
  }

  void drawElementsInstanced(int mode, int count, int type, int offset, int instanceCount) {
    startCheck("drawElementsInstanced");
    glDrawElementsInstanced(_gl, mode, count, type, offset, instanceCount);
    checkError('drawElementsInstanced');
  }

  void activeTexture(int v0) {
    startCheck("activeTexture");
    glActiveTexture(_gl, v0);
    checkError('activeTexture');
  }

  void texParameteri(int target, int pname, int param) {
    startCheck("texParameteri");
    glTexParameteri(_gl, target, pname, param);
    checkError('texParameteri');
  }

  int getParameter(int key) {
    startCheck("getParameter");
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
      WebGL.VIEWPORT
    ];

    if (_intValues.contains(key)) {
      Object? val = glGetParameter(_gl, key)?.dartify();

      if(val is List<int>){
        return ByteData.view(Uint8List.fromList(val).buffer).getUint32(0);
      }
      else if(val is double){
        return val.toInt();
      }
      else if(val is bool){
        return val?1:0;
      }
      return val as int;
    } 
    else {
      return key;
      //throw (" OpenGL getParameter key: ${key} is not support ");
    }
  }

  Future<Image> loadImageFromAsset(String assetPath) async {
    startCheck("loadImageFromAsset");
    final bytes = await rootBundle.load(assetPath);
    final loadingCompleter = Completer<Image>();
    decodeImageFromList(bytes.buffer.asUint8List(), (image) {
      loadingCompleter.complete(image);
    });
    return loadingCompleter.future;
  }

  Future<void> texImage2DfromImage(
    int target,
    Image image, {
    int level = 0,
    int internalformat = WebGL.RGBA,
    int format = WebGL.RGBA,
    int type = WebGL.UNSIGNED_BYTE,
  }) async {
    startCheck('texImage2DfromImage');
    final completer = Completer<void>();
    final bytes = (await image.toByteData())!;
    final hblob = html.Blob([bytes].jsify() as JSArray<JSAny>);
    final imageDom = html.HTMLImageElement();
    imageDom.crossOrigin = "";
    imageDom.src = html.URL.createObjectURL(hblob);
    
    imageDom.onLoad.listen((e) {
      completer.complete();
      glTexImage2D_NOSIZE(_gl,target, level, internalformat, format, type, imageDom);
    });
    
    return completer.future;
  }

  Future<void> texImage2DfromAsset(
    int target,
    String asset, {
    int level = 0,
    int internalformat = WebGL.RGBA,
    int format = WebGL.RGBA,
    int type = WebGL.UNSIGNED_BYTE,
  }) async {
    startCheck('texImage2DfromAsset');
    final completer = Completer<void>();
    final imageDom = html.HTMLImageElement();
    imageDom.crossOrigin = "";
    imageDom.src = asset;
    imageDom.onLoad.listen((e) {
      texImage2D_NOSIZE(target, level, internalformat, format, type, imageDom);
      completer.complete();
    });

    return completer.future;
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
    glTexImage2D(_gl, target, level, internalformat, width, height, border, format, type, pixels?.toJS);
    checkError('texImage2D');
  }

  void texImage2D_NOSIZE(    
    int target, 
    int level, 
    int internalformat, 
    int format, 
    int type, 
    html.HTMLElement? pixels
  ) { 
    startCheck('texImage2D_NOSIZE');
    glTexImage2D_NOSIZE(_gl, target, level, internalformat, format, type, pixels);
    checkError('texImage2D_NOSIZE');
  }

  void texImage3D(int target, int level, int internalformat, int width, int height, int depth, int border, int format, int type, NativeArray? pixels) {
    startCheck("texImage3D");
    glTexImage3D(_gl, target, level, internalformat, width, height, depth,border, format, type, pixels?.toJS);
    checkError('texImage3D');
  }

  void depthFunc(int v0) {
    startCheck("depthFunc");
    glDepthFunc(_gl, v0);
    checkError('depthFunc');
  }

  void depthMask(bool v0) {
    startCheck("depthMask");
    glDepthMask(_gl, v0);
    checkError('depthMask');
  }

  void enable(int v0) {
    startCheck("enable");
    glEnable(_gl, v0);
    checkError('enable');
  }

  void disable(int v0) {
    startCheck("disable");
    glDisable(_gl, v0);
    checkError('disable');
  }

  void blendEquation(int v0) {
    startCheck("blendEquation");
    glBlendEquation(_gl, v0);
    checkError('blendEquation');
  }

  void useProgram(Program? program) {
    startCheck("useProgram");
    glUseProgram(_gl, program?.id);
    checkError('useProgram');
  }

  void blendFuncSeparate(int srcRGB, int dstRGB, int srcAlpha, int dstAlpha) {
    startCheck("blendFuncSeparate");
    glBlendFuncSeparate(_gl, srcRGB, dstRGB, srcAlpha, dstAlpha);
    checkError('blendFuncSeparate');
  }

  void blendFunc(int sfactor, int dfactor){
    startCheck("blendFunc");
    glBlendFunc(_gl, sfactor, dfactor);
    checkError('blendFunc');
  }

  void blendEquationSeparate(int modeRGB, int modeAlpha){
    startCheck("blendEquationSeparate");
    glBlendEquationSeparate(_gl, modeRGB, modeAlpha);
    checkError('blendEquationSeparate');
  }

  void frontFace(int mode) {
    startCheck("frontFace");
    glFrontFace(_gl, mode);
    checkError('frontFace');
  }

  void cullFace(int mode) {
    startCheck("cullFace");
    glCullFace(_gl, mode);
    checkError('cullFace');
  }

  void lineWidth(double width) {
    startCheck("lineWidth");
    glLineWidth(_gl, width);
    checkError('lineWidth');
  }

  void polygonOffset(double factor, double units) {
    startCheck("polygonOffset");
    glPolygonOffset(_gl, factor, units);
    checkError('polygonOffset');
  }

  void stencilMask(int mask) {
    startCheck("stencilMask");
    glStencilMask(_gl, mask);
    checkError('stencilMask');
  }

  void stencilFunc(int func, int ref, int mask){
    startCheck("stencilFunc");
    glStencilFunc(_gl, func, ref, mask);
    checkError('stencilFunc');
  }

  void stencilOp(int fail, int zfail, int zpass){
    startCheck("stencilOp");
    glStencilOp(_gl, fail, zfail, zpass);
    checkError('stencilOp');
  }

  void clearStencil(int s) {
    startCheck("clearStencil");
    glClearStencil(_gl, s);
    checkError('clearStencil');
  }

  void clearDepth(double depth){
    startCheck("clearDepth");
    glClearDepth(_gl, depth);
    checkError('clearDepth');
  }

  void colorMask(bool red, bool green, bool blue, bool alpha){
    startCheck("colorMask");
    glColorMask(_gl, red, green, blue, alpha);
    checkError('colorMask');
  }

  void clearColor(double red, double green, double blue, double alpha){
    startCheck("clearColor");
    glClearColor(_gl, red, green, blue, alpha);
    checkError('clearColor');
  }

  void compressedTexImage2D(int target, int level, int internalformat, int width, int height, int border, NativeArray? data){
    startCheck("compressedTexImage2D");
    glCompressedTexImage2D(_gl, target, level, internalformat, width, height, border, data?.toJS);
    checkError('compressedTexImage2D');
  }

  void generateMipmap(int target) {
    startCheck("generateMipmap");
    glGenerateMipmap(_gl, target);
    checkError('generateMipmap');
  }

  void deleteTexture(WebGLTexture? texture) {
    startCheck("deleteTexture");
    glDeleteTexture(_gl, texture?.id);
    checkError('deleteTexture');
  }

  void deleteFramebuffer(Framebuffer? framebuffer) {
    startCheck("deleteFramebuffer");
    glDeleteFramebuffer(_gl, framebuffer?.id);
    checkError('deleteFramebuffer');
  }

  void deleteRenderbuffer(Renderbuffer? renderbuffer) {
    startCheck("deleteRenderbuffer");
    glDeleteRenderbuffer(_gl, renderbuffer?.id);
    checkError('deleteRenderbuffer');
  }

  void texParameterf(int target, int pname, double param) {
    startCheck("texParameterf");
    glTexParameterf(_gl, target, pname, param);
    checkError('texParameterf');
  }

  void pixelStorei(int pname, int param) {
    startCheck("pixelStorei");
    glPixelStorei(_gl, pname, param);
    checkError('pixelStorei');
  }

  dynamic getContextAttributes() {
    startCheck("getContextAttributes");
    return glGetContextAttributes(_gl);
  }

  WebGLParameter getProgramParameter(Program program, int pname) {
    startCheck("getProgramParameter");
    return WebGLParameter(glGetProgramParameter(_gl, program.id, pname).dartify());
  }

  ActiveInfo getActiveUniform(Program v0, v1) {
    startCheck("getActiveUniform");
    final dynamic temp = glGetActiveUniform(_gl, v0.id, v1).dartify();
    return ActiveInfo(temp['type'].toInt(), temp['name'], temp['size'].toInt());
    // return ActiveInfo(
    //   val.type,
    //   val.name,
    //   val.size
    // );
  }
  
  ActiveInfo getActiveAttrib(Program v0, v1) {
    startCheck("getActiveAttrib");
    final dynamic temp = glGetActiveAttrib(_gl, v0.id, v1).dartify();
    return ActiveInfo(temp['type'].toInt(), temp['name'], temp['size'].toInt());
    // return ActiveInfo(
    //   val.type,
    //   val.name,
    //   val.size
    // );
  }

  UniformLocation getUniformLocation(Program program, String name) {
    startCheck("UniformLocation");
    return UniformLocation(glGetUniformLocation(_gl, program.id, name));
  }

  void clear(int mask) {
    startCheck("clear");
    glClear(_gl, mask);
    checkError('clear');
  }

  Buffer createBuffer() {
    startCheck("createBuffer");
    return Buffer(glCreateBuffer(_gl, ));
  }

  void clearBufferuiv(int buffer,int drawbuffer, int value){
    startCheck("clearBufferuiv");
    glClearBufferuiv(_gl, buffer,drawbuffer,value);
    checkError('clearBufferuiv');
  }

  void clearBufferiv(int buffer,int drawbuffer, int value){
    startCheck("clearBufferiv");
    glClearBufferiv(_gl, buffer,drawbuffer,value);
    checkError('clearBufferiv');
  }

  void bindBuffer(int target, Buffer? buffer) {
    startCheck("bindBuffer");
    glBindBuffer(_gl, target, buffer?.id);
    checkError('bindBuffer');
  }
  void bindBufferBase(int target,int index, Buffer? buffer){
    startCheck("bindBufferBase");
    glBindBufferBase(_gl, target, index, buffer?.id);
    checkError('bindBufferBase');
  }
  // void bufferData(int target, offset, int? usage) {
  //   glBufferData(_gl, target, offset, usage);
  //   checkError('bufferData');
  // }
  /// Be careful which type of integer you really pass here. Unfortunately an UInt16List
  /// is viewed by the Dart type system just as List<int>, so we jave to specify the native type
  /// here in [nativeType]
  void bufferData(int target, dynamic data, int? usage) {
    startCheck("bufferData");
    if(data is int){
      glBufferDatai(_gl, target, data, usage ?? 0);
    }
    else{
      glBufferData(_gl, target, (data.data as TypedData).jsify(), usage ?? 0);
    }
    
    checkError('bufferData');
  }
  void vertexAttribPointer(int index, int size, int type, bool normalized, int stride, int offset) {
    startCheck("vertexAttribPointer");
    glVertexAttribPointer(_gl, index, size, type, normalized, stride, offset);
    checkError('vertexAttribPointer');
  }

  void drawArrays(int mode, int first, int count) {
    startCheck("drawArrays");
    glDrawArrays(_gl, mode, first, count);
    checkError('drawArrays');
  }

  void drawArraysInstanced(int mode, int first, int count, int instanceCount){
    startCheck("drawArraysInstanced");
    glDrawArraysInstanced(_gl, mode, first, count, instanceCount);
    checkError('drawArraysInstanced');
  }

  void bindFramebuffer(int target, Framebuffer? framebuffer){
    startCheck("bindFramebuffer");
    glBindFramebuffer(_gl, target, framebuffer?.id);
    checkError('bindFramebuffer');
  }
  
  int checkFramebufferStatus(int target) {
    startCheck("checkFramebufferStatus");
    return glCheckFramebufferStatus(_gl, target);
  }

  void framebufferTextureLayer(int target,int attachment,int texture,int level,int layer){
    startCheck("framebufferTextureLayer");
    glFramebufferTextureLayer(_gl, target, attachment, texture, level, layer);
    checkError('framebufferTextureLayer');
  }

  void framebufferTexture2D(int target, int attachment, int textarget, WebGLTexture? texture, int level){
    startCheck("framebufferTexture2D");
    glFramebufferTexture2D(_gl, target, attachment, textarget, texture?.id, level);
    checkError('framebufferTexture2D');
  }

  void readPixels(int x, int y, int width, int height, int format, int type, TypedData pixels) {
    startCheck("readPixels");
    glReadPixels(_gl, x, y, width, height, format, type, pixels.jsify());
    checkError('readPixels');
  }

  bool isProgram(Program program){
    startCheck("Program");
    return glIsProgram(_gl, program.id) != 0;
  }

  void copyTexImage2D(int target, int level, int internalformat, int x, int y, int width, int height, int border){
    startCheck("copyTexImage2D");
    glCopyTexImage2D(_gl, target, level, internalformat, x, y, width, height, border);
    checkError('copyTexImage2D');
  }

  void copyTexSubImage2D(int target, int level, int xoffset, int yoffset, int x, int y, int width, int height){
    startCheck("copyTexSubImage2D");
    glCopyTexSubImage2D(_gl, target, level, xoffset, yoffset, x, y, width, height);
    checkError('copyTexSubImage2D');
  }

  void copyTexSubImage3D(int target, int level, int xoffset, int yoffset, int zoffset, int x, int y, int width, int height){
    startCheck("copyTexSubImage3D");
    glCopyTexSubImage3D(_gl, target, level, xoffset, yoffset, zoffset, x, y, width, height);
    checkError('copyTexSubImage3D');
  }

  void texSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, int type, NativeArray? pixels) {
    startCheck("texSubImage2D");
    glTexSubImage2D(_gl, target, level, xoffset, yoffset, width, height, format, type, pixels?.toJS);
    checkError('texSubImage2D');
  }

  void texSubImage2D_NOSIZE(int target, int level, int xoffset, int yoffset, int format, int type, pixels){
    startCheck("texSubImage2D_NOSIZE");
    glTexSubImage2D_NOSIZE(_gl, target, level, xoffset, yoffset, format, type, pixels);
    checkError('texSubImage2D_NOSIZE');
  }

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
  ) {
    startCheck('texSubImage3D');
    glTexSubImage3D(_gl, target, level, xoffset, yoffset, zoffset, width,height, depth, format, type, pixels?.toJS);
    checkError('texSubImage3D');
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
    glCompressedTexSubImage3D(_gl, target,level,xoffset,yoffset,zoffset,width,height,depth,format,pixels?.toJS);
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
    startCheck("compressedTexImage3D");
    glCompressedTexImage3D(_gl, target,level,internalformat,width,height,depth,border,pixels?.toJS);
    checkError('compressedTexImage3D');
  }

  void compressedTexSubImage2D(int target, int level, int xoffset, int yoffset, int width, int height, int format, NativeArray? pixels) {
    startCheck("compressedTexSubImage2D");
    glCompressedTexSubImage2D(_gl, target, level, xoffset, yoffset, width, height, format, pixels?.toJS);
    checkError('compressedTexSubImage2D');
  }

  void bindRenderbuffer(int target, Renderbuffer? framebuffer){
    startCheck("bindRenderbuffer");
    glBindRenderbuffer(_gl, target, framebuffer?.id);
    checkError('bindRenderbuffer');
  }

  void renderbufferStorageMultisample(int target, int samples, int internalformat, int width, int height){
    startCheck("renderbufferStorageMultisample");
    glRenderbufferStorageMultisample(_gl, target, samples, internalformat, width, height);
    checkError('renderbufferStorageMultisample');
  }

  void renderbufferStorage(int target, int internalformat, int width, int height){
    startCheck("renderbufferStorage");
    glRenderbufferStorage(_gl, target, internalformat, width, height);
    checkError('renderbufferStorage');
  }

  void framebufferRenderbuffer(int target, int attachment, int renderbuffertarget, Renderbuffer? renderbuffer){
    startCheck("framebufferRenderbuffer");
    glFramebufferRenderbuffer(_gl, target, attachment, renderbuffertarget, renderbuffer?.id);
    checkError('framebufferRenderbuffer');
  }

  Renderbuffer createRenderbuffer() {
    startCheck("createRenderbuffer");
    return Renderbuffer(glCreateRenderbuffer(_gl, ));
  }

  Framebuffer createFramebuffer() {
    startCheck("createFramebuffer");
    return Framebuffer(glCreateFramebuffer(_gl, ));
  }

  void blitFramebuffer(int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, int mask, int filter){
    startCheck("blitFramebuffer");
    glBlitFramebuffer(_gl, srcX0, srcY0, srcX1, srcY1, dstX0, dstY0, dstX1, dstY1, mask, filter);
    checkError('blitFramebuffer');
  }

  void bufferSubData(int target, int dstByteOffset, NativeArray srcData){
    startCheck("bufferSubData");
    glBufferSubData(_gl, target, dstByteOffset, srcData.toJS);
    checkError('bufferSubData');
  }

  VertexArrayObject createVertexArray() {
    startCheck("VertexArrayObject");
    return VertexArrayObject(glCreateVertexArray(_gl));
  }

  Program createProgram() {
    startCheck("createProgram");
    return Program(glCreateProgram(_gl));
  }

  void attachShader(Program program, WebGLShader shader) {
    startCheck("attachShader");
    glAttachShader(_gl, program.id, shader.id);
    checkError('attachShader');
  }

  void bindAttribLocation(Program program, int index, String name){
    startCheck("bindAttribLocation");
    glBindAttribLocation(_gl, program.id, index, name);
    checkError('bindAttribLocation');
  }

  void linkProgram(Program program, [bool checkForErrors = true]) {
    startCheck("linkProgram");
    glLinkProgram(_gl, program.id);
    checkError('linkProgram');
  }

  String? getProgramInfoLog(Program program){
    startCheck("getProgramInfoLog");
    return glGetProgramInfoLog(_gl, program.id);
  }

  String? getShaderInfoLog(WebGLShader shader) {
    startCheck("getShaderInfoLog");
    return glGetShaderInfoLog(_gl, shader.id);
  }

  int getError() {
    startCheck("getError");
    return glGetError(_gl, );
  }

  void deleteShader(WebGLShader shader) {
    startCheck("deleteShader");
    glDeleteShader(_gl, shader.id);
    checkError('deleteShader');
  }

  void deleteProgram(Program program) {
    startCheck("deleteProgram");
    glDeleteProgram(_gl, program.id);
    checkError('deleteProgram');
  }

  void deleteBuffer(Buffer buffer) {
    startCheck("deleteBuffer");
    glDeleteBuffer(_gl, buffer.id);
    checkError('deleteBuffer');
  }

  void bindVertexArray(VertexArrayObject array) {
    startCheck("bindVertexArray");
    glBindVertexArray(_gl, array.id);
    checkError('bindVertexArray');
  }

  void deleteVertexArray(VertexArrayObject array) {
    startCheck("deleteVertexArray");
    glDeleteVertexArray(_gl, array.id);
    checkError('deleteVertexArray');
  }

  void enableVertexAttribArray(int index) {
    startCheck("enableVertexAttribArray");
    glEnableVertexAttribArray(_gl, index);
    checkError('enableVertexAttribArray');
  }

  void disableVertexAttribArray(int index) {
    startCheck("disableVertexAttribArray");
    glDisableVertexAttribArray(_gl, index);
    checkError('disableVertexAttribArray');
  }

  void vertexAttribIPointer(int index, int size, int type, int stride, int pointer){
    startCheck("vertexAttribIPointer");
    glVertexAttribIPointer(_gl, index, size, type, stride, pointer);
    checkError('vertexAttribIPointer');
  }

  void vertexAttrib2fv(int index, List<double> values) {
    startCheck("vertexAttrib2fv");
    glVertexAttrib2fv(_gl, index, values.jsify());
    checkError('vertexAttrib2fv');
  }

  void vertexAttrib3fv(int index, List<double> values) {
    startCheck("vertexAttrib3fv");
    glVertexAttrib3fv(_gl, index, values.jsify());
    checkError('vertexAttrib3fv');
  }

  void vertexAttrib4fv(int index, List<double> values) {
    startCheck("vertexAttrib4fv");
    glVertexAttrib4fv(_gl, index, values.jsify());
    checkError('vertexAttrib4fv');
  }

  void vertexAttrib1fv(int index, List<double> values) {
    startCheck("vertexAttrib1fv");
    glVertexAttrib1fv(_gl, index, values.jsify());
    checkError('vertexAttrib1fv');
  }

  void drawElements(int mode, int count, int type, int offset) {
    startCheck("drawElements");
    glDrawElements(_gl, mode, count, type, offset);
    checkError('drawElements');
  }

  void drawBuffers(NativeArray buffers) {
    startCheck("drawBuffers");
    glDrawBuffers(_gl, buffers.toJS);
    checkError('drawBuffers');
  }

  WebGLShader createShader(int type) {
    startCheck("createShader");
    return WebGLShader(glCreateShader(_gl, type));
  }

  void shaderSource(WebGLShader shader, String shaderSource) {
    startCheck("shaderSource");
    glShaderSource(_gl, shader.id, shaderSource);
    checkError('shaderSource');
  }

  void compileShader(WebGLShader shader) {
    startCheck("compileShader");
    glCompileShader(_gl, shader.id);
    checkError('compileShader');
  }

  bool getShaderParameter(WebGLShader shader, int pname){
    startCheck("getShaderParameter");
    return glGetShaderParameter(_gl, shader.id, pname);
  }

  String? getShaderSource(WebGLShader shader) {
    startCheck("getShaderSource");
    return glGetShaderSource(_gl, shader.id);
  }

  void uniform1i(UniformLocation location, int x) {
    startCheck("uniform1i");
    glUniform1i(_gl, location.id, x);
    checkError('uniform1i');
  }

  void uniform3f(UniformLocation location, double x, double y, double z) {
    startCheck("uniform3f");
    glUniform3f(_gl, location.id, x, y, z);
    checkError('uniform3f');
  }

  void uniform4f(UniformLocation location, double x, double y, double z, double w){
    startCheck("uniform4f");
    glUniform4f(_gl, location.id, x, y, z,w);
    checkError('uniform4f');
  }

  void uniform1fv(UniformLocation location, List<double> v){
    startCheck("uniform1fv");
    glUniform1fv(_gl, location.id, v.jsify());
    checkError('uniform1fv');
  }

  void uniform2fv(UniformLocation location, List<double> v){
    startCheck("uniform2fv");
    glUniform2fv(_gl, location.id, v.jsify());
    checkError('uniform2fv');
  }

  void uniform3fv(UniformLocation location, List<double> v){
    startCheck("uniform3fv");
    glUniform3fv(_gl, location.id, v.jsify());
    checkError('uniform3fv');
  }

  void uniform1f(UniformLocation location, double x){
    startCheck("uniform1f");
    glUniform1f(_gl, location.id, x);
    checkError('uniform1f');
  }
  void uniformMatrix2fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck("uniformMatrix2fv");
    glUniformMatrix2fv(_gl, location.id, transpose, values.jsify());
    checkError('uniformMatrix2fv');
  }

  void uniformMatrix3fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck("uniformMatrix3fv");
    glUniformMatrix3fv(_gl, location.id, transpose, values.jsify());
    checkError('uniformMatrix3fv');
  }

  void uniformMatrix4fv(UniformLocation location, bool transpose, List<double> values) {
    startCheck("uniformMatrix4fv");
    glUniformMatrix4fv(_gl, location.id, transpose, values.jsify());
    checkError('uniformMatrix4fv');
  }

  UniformLocation getAttribLocation(Program program, String name) {
    startCheck("getAttribLocation");
    return UniformLocation(glGetAttribLocation(_gl, program.id, name));
  }

  void uniform2f(UniformLocation location, double x, double y){
    startCheck("uniform2f");
    glUniform2f(_gl, location.id, x, y);
    checkError('uniform2f');
  }

  void uniform1iv(UniformLocation location, List<int> v){
    startCheck("uniform1iv");
    glUniform1iv(_gl, location.id, v.jsify());
    checkError('uniform1iv');
  }

  void uniform2iv(UniformLocation location, List<int> v){
    startCheck("uniform2iv");
    glUniform2iv(_gl, location.id, v.jsify());
    checkError('uniform2iv');
  }

  void uniform3iv(UniformLocation location, List<int> v){
    startCheck("uniform3iv");
    glUniform3iv(_gl, location.id, v.jsify());
    checkError('uniform3iv');
  }

  void uniform4iv(UniformLocation location, List<int> v){
    startCheck("uniform4iv");
    glUniform4iv(_gl, location.id, v.jsify());
    checkError('uniform4iv');
  }

  void uniform1uiv(UniformLocation? location, List<int> v){
    startCheck("uniform1uiv");
    glUniform1uiv(_gl, location?.id, v.jsify());
    checkError('uniform1uiv');
  }
  
  void uniform2uiv(UniformLocation? location, List<int> v){
    startCheck("uniform2uiv");
    glUniform2uiv(_gl, location?.id, v.jsify());
    checkError('uniform2uiv');
  }

  void uniform3uiv(UniformLocation? location, List<int> v){
    startCheck("uniform3uiv");
    glUniform3uiv(_gl, location?.id, v.jsify());
    checkError('uniform3uiv');
  }

  void uniform4uiv(UniformLocation? location, List<int> v){
    startCheck("uniform4uiv");
    glUniform4uiv(_gl, location?.id, v.jsify());
    checkError('uniform4uiv');
  }

  void uniform1ui(UniformLocation? location, int v0){
    startCheck("uniform1ui");
    glUniform1ui(_gl, location?.id, v0);
    checkError('uniform1ui');
  }

  void uniform2ui(UniformLocation? location, int v0, int v1){
    startCheck("uniform2ui");
    glUniform2ui(_gl, location?.id, v0, v1);
    checkError('uniform2ui');
  }

  void uniform3ui(UniformLocation? location, int v0, int v1, int v2){
    startCheck("uniform3ui");
    glUniform3ui(_gl, location?.id, v0, v1, v2);
    checkError('uniform2ui');
  }

  void uniform4ui(UniformLocation? location, int v0, int v1, int v2, int v3){
    startCheck("uniform4ui");
    glUniform4ui(_gl, location?.id, v0, v1, v2, v3);
    checkError('uniform2ui');
  }

  void uniform4fv(UniformLocation location, List<double> vectors) {
    startCheck("uniform4fv");
    glUniform4fv(_gl, location.id, vectors.jsify());
    checkError('uniform4fv');
  }

  void vertexAttribDivisor(int index, int divisor){
    startCheck("vertexAttribDivisor");
    glVertexAttribDivisor(_gl, index, divisor);
    checkError('vertexAttribDivisor');
  }

  void flush() {
    startCheck("flush");
    glFlush(_gl);
    checkError('flush');
  }

  void finish() {
    startCheck("finish");
    glFinish(_gl);
    checkError('finish');
  }

  void texStorage2D(int target, int levels, int internalformat, int width, int height){
    startCheck("texStorage2D");
    glTexStorage2D(_gl, target, levels, internalformat, width, height);
    checkError('texStorage2D');
  }

  void texStorage3D(int target, int levels, int internalformat, int width, int height, int depth){
    startCheck("texStorage3D");
    glTexStorage3D(_gl, target, levels, internalformat, width, height, depth);
    checkError('texStorage3D');
  }

  TransformFeedback createTransformFeedback() {
    startCheck("createTransformFeedback");
    return TransformFeedback(glCreateTransformFeedback(_gl, ));
  }
  
  void bindTransformFeedback(int target, TransformFeedback feedbeck){
    startCheck("bindTransformFeedback");
    glBindTransformFeedback(_gl, target, feedbeck.id);
    checkError('bindTransformFeedback');
  }

  void transformFeedbackVaryings(Program program, int count, List<String> varyings, int bufferMode) {
    startCheck("transformFeedbackVaryings");
    glTransformFeedbackVaryings(_gl, program.id, varyings.jsify(), bufferMode);
    checkError('transformFeedbackVaryings');
  }

  void deleteTransformFeedback(TransformFeedback transformFeedback) {
    startCheck("deleteTransformFeedback");
    glDeleteTransformFeedback(_gl, transformFeedback.id);
    checkError('deleteTransformFeedback');
  }

  bool isTransformFeedback(TransformFeedback transformFeedback) {
    startCheck("isTransformFeedback");
    return glIsTransformFeedback(_gl, transformFeedback.id);
  }

  void beginTransformFeedback(int primitiveMode) {
    startCheck("beginTransformFeedback");
    glBeginTransformFeedback(_gl, primitiveMode);
    checkError('beginTransformFeedback');
  }

  void endTransformFeedback() {
    startCheck("endTransformFeedback");
    glEndTransformFeedback(_gl, );
    checkError('endTransformFeedback');
  }

  void pauseTransformFeedback() {
    startCheck("pauseTransformFeedback");
    glPauseTransformFeedback(_gl, );
    checkError('pauseTransformFeedback');
  }

  void resumeTransformFeedback() {
    startCheck("resumeTransformFeedback");
    glResumeTransformFeedback(_gl, );
    checkError('resumeTransformFeedback');
  }

  ActiveInfo getTransformFeedbackVarying( program, int index) {
    startCheck("getTransformFeedbackVarying");
    final dynamic temp = glGetTransformFeedbackVarying(_gl, program, index).dartify();
    return ActiveInfo(temp['type'].toInt(), temp['name'], temp['size'].toInt());
  }

  void invalidateFramebuffer(int target, List<int> attachments){
    startCheck("invalidateFramebuffer");
    glInvalidateFramebuffer(_gl, target, attachments.jsify());
    checkError('invalidateFramebuffer');
  }

  Future<void> makeXRCompatible() async{
    JSPromise<JSAny?> jsp = glMakeXRCompatible(_gl);
    await jsp.toDart;
  }

  set drawingBufferColorSpace(cspace) => glDrawingBufferColorSpace(_gl,cspace);
  set unpackColorSpace(cspace) => glUnpackColorSpace(_gl,cspace);
}