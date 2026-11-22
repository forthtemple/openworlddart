import 'dart:js_interop';

@JS()
external JSObject glCanvas(JSObject id, JSAny? options);

@JS()
external JSPromise<JSAny?> glMakeXRCompatible(JSObject gl);

@JS()
external void glScissor(JSObject gl, int x, int y, int width, int height);
@JS()
external void glViewport(JSObject gl, int x, int y, int width, int height);
@JS()
external JSObject glGetShaderPrecisionFormat(JSObject gl);

@JS()
external JSAny? glGetExtension(JSObject gl,String key);
@JS()
external JSAny? glGetParameter(JSObject gl,int key);
@JS()
external JSAny? glGetString(JSObject gl,String key);

@JS()
external JSObject createTexture(JSObject gl);
@JS()
external void glBindTexture(JSObject gl, int type, JSAny? texture);
@JS()
external void glDrawElementsInstanced(JSObject gl, int mode, int count, int type, int offset, int instanceCount);
@JS()
external void glActiveTexture(JSObject gl, int v0);
@JS()
external void glTexParameteri(JSObject gl, int target, int pname, int param);

@JS()
external void glTexImage2D(
  JSObject gl, 
  int target, 
  int level, 
  int internalformat, 
  int width, 
  int height, 
  int border, 
  int format, 
  int type, 
  JSAny? pixels
);

@JS()
external void glTexImage2D_NOSIZE(
  JSObject gl,     
  int target, 
  int level, 
  int internalformat,
  int format, 
  int type, 
  JSAny? pixels
);

// @JS()
// external void glTexImage2D_NOSIZE_element(
//   JSObject gl,     
//   int target, 
//   int level, 
//   int internalformat, 
//   int format, 
//   int type, 
//   JSObject? pixels
// );

@JS()
external void glTexImage3D(JSObject gl, int target, int level, int internalformat, int width, int height, int depth, int border, int format, int type, JSAny? pixels);
@JS()
external void glDepthFunc(JSObject gl, int v0);
@JS()
external void glDepthMask(JSObject gl, bool v0);
@JS()
external void glEnable(JSObject gl, int v0);
@JS()
external void glDisable(JSObject gl, int v0);
@JS()
external void glBlendEquation(JSObject gl, int v0);
@JS()
external void glUseProgram(JSObject gl, JSAny? program);

@JS()
external void glBlendFuncSeparate(JSObject gl, int srcRGB, int dstRGB, int srcAlpha, int dstAlpha);
@JS()
external void glBlendFunc(JSObject gl, int sfactor, int dfactor);
@JS()
external void glBlendEquationSeparate(JSObject gl, int modeRGB, int modeAlpha);
@JS()
external void glFrontFace(JSObject gl, int mode);

@JS()
external void glCullFace(JSObject gl, int mode);
@JS()
external void glLineWidth(JSObject gl, double width);
@JS()
external void glPolygonOffset(JSObject gl, double factor, double units);
@JS()
external void glStencilMask(JSObject gl, int mask);
@JS()
external void glStencilFunc(JSObject gl, int func, int ref, int mask);
@JS()
external void glStencilOp(JSObject gl, int fail, int zfail, int zpass);
@JS()
external void glClearStencil(JSObject gl, int s);
@JS()
external void glClearDepth(JSObject gl, double depth);
@JS()
external void glColorMask(JSObject gl, bool red, bool green, bool blue, bool alpha);
@JS()
external void glClearColor(JSObject gl, double red, double green, double blue, double alpha);
@JS()
external void glCompressedTexImage2D(JSObject gl, int target, int level, int internalformat, int width, int height, int border, JSAny? data);
@JS()
external void glGenerateMipmap(JSObject gl, int target);
@JS()
external void glDeleteTexture(JSObject gl, JSAny? v0);
@JS()
external void glDeleteFramebuffer(JSObject gl, JSAny? framebuffer);
@JS()
external void glDeleteRenderbuffer(JSObject gl, JSAny? renderbuffer);
@JS()
external void glTexParameterf(JSObject gl, int target, int pname, double param);
@JS()
external void glPixelStorei(JSObject gl, int pname, int param);
@JS()
external JSAny? glGetContextAttributes(JSObject gl);
@JS()
external JSAny? glGetProgramParameter(JSObject gl, JSAny? program, int pname);
@JS()
external JSAny? glGetActiveUniform(JSObject gl, JSAny? v0, int v1);
@JS()
external JSAny? glGetActiveAttrib(JSObject gl, JSAny? v0, int v1);
@JS()
external JSAny? glGetUniformLocation(JSObject gl, JSAny? program, String name);
@JS()
external void glClear(JSObject gl, int mask);
@JS()
external JSAny? glCreateBuffer(JSObject gl);
@JS()
external void glBindBuffer(JSObject gl, int target, JSAny? buffer);
@JS()
external void glBufferData(JSObject gl, int target, JSAny? data, int usage);
@JS()
external void glBufferDatai(JSObject gl, int target, int data, int usage);
@JS()
external void glVertexAttribPointer(JSObject gl, int index, int size, int type, bool normalized, int stride, int offset);
@JS()
external void glDrawArrays(JSObject gl, int mode, int first, int count);
@JS()
external void glDrawArraysInstanced(JSObject gl, int mode, int first, int count, int instanceCount);
@JS()
external void glBindFramebuffer(JSObject gl, int target, JSAny? framebuffer);
@JS()
external int glCheckFramebufferStatus(JSObject gl, int target);
@JS()
external void glFramebufferTexture2D(JSObject gl, int target, int attachment, int textarget, JSAny? texture, int level);
@JS()
external void glReadPixels(JSObject gl, int x, int y, int width, int height, int format, int type, JSAny? pixels);
@JS()
external bool glIsProgram(JSObject gl, JSAny? program);
@JS()
external void glCopyTexImage2D(JSObject gl, int target, int level, int internalformat, int x, int y, int width, int height, int border);
@JS()
external void glTexSubImage2D(JSObject gl, int target, int level, int xoffset, int yoffset, int width, int height, int format, int type, JSAny? pixels) ;
@JS()
external void glTexSubImage2D_NOSIZE(JSObject gl, int target, int level, int xoffset, int yoffset, int format, int type, JSAny? pixels);

@JS()
external void glTexSubImage3D(JSObject gl, 
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
  JSAny? pixels
);

@JS()
external void glCompressedTexSubImage2D(JSObject gl, int target, int level, int xoffset, int yoffset, int width, int height, int format, JSAny? pixels);
@JS()
external void glBindRenderbuffer(JSObject gl, int target, JSAny? framebuffer);
@JS()
external void glRenderbufferStorageMultisample(JSObject gl, int target, int samples, int internalformat, int width, int height);
@JS()
external void glRenderbufferStorage(JSObject gl, int target, int internalformat, int width, int height);
@JS()
external void glFramebufferRenderbuffer(JSObject gl, int target, int attachment, int renderbuffertarget, JSAny? renderbuffer);
@JS()
external JSAny? glCreateRenderbuffer(JSObject gl);
@JS()
external void glGenRenderbuffers(JSObject gl, int count, JSAny buffers);
@JS()
external JSAny? glCreateFramebuffer(JSObject gl);
@JS()
external void glGenFramebuffers(JSObject gl, int count, JSAny buffers);
@JS()
external void glBlitFramebuffer(JSObject gl, int srcX0, int srcY0, int srcX1, int srcY1, int dstX0, int dstY0, int dstX1, int dstY1, int mask, int filter);
@JS()
external void glBufferSubData(JSObject gl, int target, int dstByteOffset, JSAny srcData);
@JS()
external JSAny? glCreateVertexArray(JSObject gl);
@JS()
external JSAny? glCreateProgram(JSObject gl);
@JS()
external void glAttachShader(JSObject gl, JSAny? program, JSAny? shader);
@JS()
external void glBindAttribLocation(JSObject gl, JSAny? program, int index, String name);
@JS()
external void glLinkProgram(JSObject gl, JSAny? program);
@JS()
external String? getProgramInfoLog(JSObject gl, JSAny? program);
@JS()
external String? getShaderInfoLog(JSObject gl, JSAny? shader);
@JS()
external int glGetError(JSObject gl);
@JS()
external void glDeleteShader(JSObject gl, JSAny? shader);
@JS()
external void glDeleteProgram(JSObject gl, JSAny? program);
@JS()
external void glDeleteBuffer(JSObject gl, JSAny? buffer);
@JS()
external void glBindVertexArray(JSObject gl, JSAny? array);
@JS()
external void glDeleteVertexArray(JSObject gl, JSAny? array);
@JS()
external void glEnableVertexAttribArray(JSObject gl, int index);
@JS()
external void glDisableVertexAttribArray(JSObject gl, int index);
@JS()
external void glVertexAttribIPointer(JSObject gl, int index, int size, int type, int stride, int pointer);
@JS()
external void glVertexAttrib2fv(JSObject gl, int index, JSAny? values);
@JS()
external void glVertexAttrib3fv(JSObject gl, int index, JSAny? values);
@JS()
external void glVertexAttrib4fv(JSObject gl, int index, JSAny? values);
@JS()
external void glVertexAttrib1fv(JSObject gl, int index, JSAny? values);
@JS()
external void glDrawElements(JSObject gl, int mode, int count, int type, int offset);
@JS()
external void glDrawBuffers(JSObject gl, JSAny buffers);
@JS()
external JSAny? glCreateShader(JSObject gl, int type);
@JS()
external void glShaderSource(JSObject gl, JSAny? shader, String shaderSource);
@JS()
external void glCompileShader(JSObject gl, JSAny? shader);
@JS()
external bool glGetShaderParameter(JSObject gl, JSAny? shader, int pname);
@JS()
external String? glGetShaderSource(JSObject gl, JSAny? shader);
@JS()
external void glUniformMatrix4fv(JSObject gl, JSAny? location, bool transpose, JSAny? values);
@JS()
external void glUniform1i(JSObject gl, JSAny? location, int x);
@JS()
external void glUniform3f(JSObject gl, JSAny? location, double x, double y, double z);
@JS()
external void glUniform4f(JSObject gl, JSAny? location, double x, double y, double z, double w);
@JS()
external void glUniform1fv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform2fv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform3fv(JSObject gl, JSAny? location, JSAny? v);

@JS()
external void glUniform1f(JSObject gl, JSObject location, double x);
@JS()
external void glUniformMatrix3fv(JSObject gl, JSAny? location, bool transpose, JSAny? values);
@JS()
external int glGetAttribLocation(JSObject gl, JSAny? program, String name);
@JS()
external void glUniform2f(JSObject gl, JSAny? location, double x, double y);
@JS()
external void glUniform1iv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform2iv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform3iv(JSObject gl, JSAny? location, JSAny? v);

@JS()
external void glUniform4iv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform4fv(JSObject gl, JSAny? location, JSAny? vectors);
@JS()
external void glVertexAttribDivisor(JSObject gl, int index, int divisor);
@JS()
external void glFlush(JSObject gl);
@JS()
external void glFinish(JSObject gl);
@JS()
external void glTexStorage2D(JSObject gl, int target, int levels, int internalformat, int width, int height);
@JS()
external void glTexStorage3D(JSObject gl, int target, int levels, int internalformat, int width, int height, int depth);
@JS()
external int glCreateTransformFeedback(JSObject gl);
@JS()
external void glBindTransformFeedback(JSObject gl, int target, JSAny? id);
@JS()
external void glTransformFeedbackVaryings(JSObject gl, JSAny? program, JSAny? varyings, int bufferMode);
@JS()
external void glDeleteTransformFeedback(JSObject gl, JSAny? transformFeedback);
@JS()
external bool isTransformFeedback(JSObject gl, JSAny? transformFeedback);
@JS()
external void glBeginTransformFeedback(JSObject gl, int primitiveMode);
@JS()
external void glEndTransformFeedback(JSObject gl);
@JS()
external void glPauseTransformFeedback(JSObject gl);
@JS()
external void glResumeTransformFeedback(JSObject gl);
@JS()
external JSAny? glGetTransformFeedbackVarying(JSObject gl, JSAny? program, int index);
@JS()
external void glInvalidateFramebuffer(JSObject gl, int target, JSAny? attachments);
@JS()
external JSAny? readCurrentPixels(JSObject gl, int x, int y, int width, int height);
@JS()
external JSAny? glCreateTexture(JSObject gl);

@JS()
external int glGetUniformBlockIndex(JSObject gl, JSAny? program, String uniformBlockName);
@JS()
external void glUniformBlockBinding(JSObject gl, JSAny? program, int uniformBlockIndex,int uniformBlockBinding);


@JS()
external void glFramebufferTextureLayer(JSObject gl, int target,int attachment, int texture,int level,int layer);
@JS()
external void glClearBufferuiv(JSObject gl, int buffer, int drawbuffer, int value);
@JS()
external void glClearBufferiv(JSObject gl, int buffer, int drawbuffer, int value);
@JS()
external void glBindBufferBase(JSObject gl, int target, int index, int buffer);
@JS()
external void glCopyTexSubImage2D(JSObject gl,int target, int level, int xoffset, int yoffset, int x, int y, int width, int height);
@JS()
external void glCopyTexSubImage3D(JSObject gl, int target, int level, int xoffset, int yoffset, int zoffset, int x, int y, int width, int height);
@JS()
external void glCompressedTexSubImage3D(JSObject gl, int target, int level, int xoffset, int yoffset, int zoffset, int width, int height, int depth, int ormat, JSAny pixels);
@JS()
external void glCompressedTexImage3D(JSObject gl, int target, int level, int internalformat, int width, int height, int depth, int border, JSAny pixels);


@JS()
external String? glGetProgramInfoLog(JSObject gl, JSAny? id);
@JS()
external String? glGetShaderInfoLog(JSObject gl, JSAny? id);
@JS()
external void glUniformMatrix2fv(JSObject gl, int id, bool transpose, JSAny? values);
@JS()
external bool glIsTransformFeedback(JSObject gl, JSAny? transformFeedback);
@JS()
external void glUniform1uiv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform2uiv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform3uiv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform4uiv(JSObject gl, JSAny? location, JSAny? v);
@JS()
external void glUniform1ui(JSObject gl, JSAny? location, int v0);
@JS()
external void glUniform2ui(JSObject gl, JSAny? location, int v0, int v1);
@JS()
external void glUniform3ui(JSObject gl, JSAny? location, int v0, int v1, int v2);
@JS()
external void glUniform4ui(JSObject gl, JSAny? location, int v0, int v1, int v2, int v3);
@JS()
external void glDrawingBufferColorSpace(JSObject gl, String colorSpace);
@JS()
external void glUnpackColorSpace(JSObject gl, String colorSpace);