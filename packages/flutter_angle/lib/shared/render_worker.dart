import 'dart:typed_data';
import 'package:flutter_angle/flutter_angle.dart';
import 'package:flutter_angle/shared/gl_program.dart';

class RenderWorker{
  late final Buffer vertexBuffer;
  late final Buffer vertexBuffer4FBO;
  late final RenderingContext _gl;
  
  RenderWorker(FlutterAngleTexture texture){
    _gl = texture.getContext();
    setupVBO();
    setupVBO4FBO();
  }

  void renderTexture(WebGLTexture? texture, {Float32List? matrix, bool isFBO = false}){
    late final Buffer _vertexBuffer;
    
    if(isFBO) {
      _vertexBuffer = vertexBuffer4FBO;
    } else {
      _vertexBuffer = vertexBuffer;
    }
    
    drawTexture(texture: texture, vertexBuffer: _vertexBuffer, matrix: matrix);
  }

  void setupVBO() {
    double w = 1.0;
    double h = 1.0;

    Float32Array vertices = Float32Array.fromList([
      -w,-h,0,0,1,
      w,-h,0,1,1,
      -w,h,0,0,0,
      w,h,0,1,0
    ]);
    
    vertexBuffer = _gl.createBuffer();
    _gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    _gl.bufferData(WebGL.ARRAY_BUFFER, vertices, WebGL.STATIC_DRAW);
    vertices.dispose();
  }
  
  void setupVBO4FBO() {
    double w = 1.0;
    double h = 1.0;

    Float32Array vertices = Float32Array.fromList([
      -w,-h,0,0,0,
      w,-h,0,1,0,
      -w,h,0,0,1,
      w,h,0,1,1,
    ]);
    
    vertexBuffer4FBO = _gl.createBuffer();
    _gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer4FBO);
    _gl.bufferData(WebGL.ARRAY_BUFFER, vertices, WebGL.STATIC_DRAW);
    vertices.dispose();
  }

  void drawTexture({required WebGLTexture? texture, required Buffer vertexBuffer, Float32List? matrix}) {
    _gl.checkError("drawTexture 01");
    
    final program = GlProgram(
      _gl,
      fragment_shader, 
      vertex_shader
    ).program;

    _gl.useProgram(program);
    _gl.checkError("drawTexture 02");
    
    final _positionSlot = _gl.getAttribLocation(program, "Position");
    final _textureSlot = _gl.getAttribLocation(program, "TextureCoords");
    final _texture0Uniform = _gl.getUniformLocation(program, "Texture0");
    
    _gl.activeTexture(WebGL.TEXTURE10);
    _gl.bindTexture(WebGL.TEXTURE_2D, texture!);
    _gl.uniform1i(_texture0Uniform, 10);
    _gl.checkError("drawTexture 03");
    
    Float32List _matrix = Float32List.fromList([
      1.0, 0.0, 0.0, 0.0,
      0.0, 1.0, 0.0, 0.0,
      0.0, 0.0, 1.0, 0.0,
      0.0, 0.0, 0.0, 1.0
    ]);
    
    if(matrix != null) {
      _matrix = matrix;
    }

    final _matrixUniform = _gl.getUniformLocation(program, "matrix");
    _gl.uniformMatrix4fv(_matrixUniform, false, _matrix);
    
    _gl.checkError("drawTexture 04");
    _gl.bindBuffer(WebGL.ARRAY_BUFFER, vertexBuffer);
    
    _gl.checkError("drawTexture 05");

    final vao = _gl.createVertexArray();
    _gl.bindVertexArray(vao);
    
    _gl.vertexAttribPointer(_positionSlot.id, 3, WebGL.FLOAT, false, Float32List.bytesPerElement * 5, 0);
    _gl.checkError("drawTexture 06");

    _gl.enableVertexAttribArray(_positionSlot.id);
    _gl.checkError("drawTexture 07");
    
    _gl.vertexAttribPointer(_textureSlot.id, 2, WebGL.FLOAT, false, Float32List.bytesPerElement * 5, Float32List.bytesPerElement * 3);
    _gl.enableVertexAttribArray(_textureSlot.id);
    
    _gl.checkError("drawTexture 08");
    _gl.drawArrays(WebGL.TRIANGLE_STRIP, 0, 4);
    _gl.deleteVertexArray(vao);
    _gl.checkError("drawTexture 09");
    _gl.deleteProgram(program);
  }

  void dispose(){
    _gl.deleteBuffer(vertexBuffer);
    _gl.deleteBuffer(vertexBuffer4FBO);
  }

  final vertex_shader = """
  #version 300 es
  precision mediump float;

  in vec4 Position;
  in vec2 TextureCoords;
  out vec2 TextureCoordsVarying;

  uniform mat4 matrix;

  void main (void) {
      gl_Position = matrix * Position;
      TextureCoordsVarying = TextureCoords;
  }

  """;
      
  final fragment_shader = """
  #version 300 es
  precision mediump float;

  uniform sampler2D Texture0;
  in vec2 TextureCoordsVarying;

  out vec4 fragColor;

  void main (void) {
      vec4 mask = texture(Texture0, TextureCoordsVarying);
      fragColor = vec4(mask.rgb, mask.a);
  }
  """;

  //#version 300 es must be at first line
  final vertex_shader_android = """
  #version 300 es
  precision mediump float;

  layout (location = 0) in vec4 Position;
  layout (location = 1) in vec2 TextureCoords;
  out vec2 TextureCoordsVarying;
  uniform mat4 matrix;

  void main () {
      gl_Position = matrix * Position;
      TextureCoordsVarying = TextureCoords;
  }
  """;


  final oes_vertex_shader = """
  #version 300 es
  precision mediump float;

  layout (location = 0) in vec4 Position;
  layout (location = 1) in vec2 TextureCoords;
  out vec2 TextureCoordsVarying;

  void main () {
      gl_Position = Position;
      TextureCoordsVarying = TextureCoords;
  }
  """;

  final oes_fragment_shader  = """
  #version 300 es
  #extension GL_OES_EGL_image_external_essl3 : enable

  precision mediump float;
  uniform samplerExternalOES Texture0;
  in vec2 TextureCoordsVarying;

  out vec4 fragColor;

  void main (void) {
    vec4 mask = texture(Texture0, TextureCoordsVarying);
    fragColor = mask;
  }
  """;


  final fxaa_vertex_shader = """
  #version 300 es
  layout (location = 0) in vec4 Position;
  layout (location = 1) in vec2 TextureCoords;
  out vec2 TextureCoordsVarying;

  void main () {
      gl_Position = Position;
      TextureCoordsVarying = TextureCoords;
  }
  """;

  final fxaa_fragment_shader = """
  #version 300 es
  precision mediump float;
  uniform sampler2D Texture0;
  uniform vec2 frameBufSize;
  in vec2 TextureCoordsVarying;

  out vec4 fragColor;

  void main( void ) {
      float FXAA_SPAN_MAX = 8.0;
      float FXAA_REDUCE_MUL = 1.0/8.0;
      float FXAA_REDUCE_MIN = 1.0/128.0;

      vec3 rgbNW=texture(Texture0,TextureCoordsVarying+(vec2(-1.0,-1.0)/frameBufSize)).xyz;
      vec3 rgbNE=texture(Texture0,TextureCoordsVarying+(vec2(1.0,-1.0)/frameBufSize)).xyz;
      vec3 rgbSW=texture(Texture0,TextureCoordsVarying+(vec2(-1.0,1.0)/frameBufSize)).xyz;
      vec3 rgbSE=texture(Texture0,TextureCoordsVarying+(vec2(1.0,1.0)/frameBufSize)).xyz;
      vec3 rgbM=texture(Texture0,TextureCoordsVarying).xyz;

      vec3 luma= vec3(0.299, 0.587, 0.114);
      float lumaNW = dot(rgbNW, luma);
      float lumaNE = dot(rgbNE, luma);
      float lumaSW = dot(rgbSW, luma);
      float lumaSE = dot(rgbSE, luma);
      float lumaM  = dot(rgbM,  luma);

      float lumaMin = min(lumaM, min(min(lumaNW, lumaNE), min(lumaSW, lumaSE)));
      float lumaMax = max(lumaM, max(max(lumaNW, lumaNE), max(lumaSW, lumaSE)));

      vec2 dir;
      dir.x = -((lumaNW + lumaNE) - (lumaSW + lumaSE));
      dir.y =  ((lumaNW + lumaSW) - (lumaNE + lumaSE));

      float dirReduce = max(
          (lumaNW + lumaNE + lumaSW + lumaSE) * (0.25 * FXAA_REDUCE_MUL),
          FXAA_REDUCE_MIN);

      float rcpDirMin = 1.0/(min(abs(dir.x), abs(dir.y)) + dirReduce);

      dir = min(vec2( FXAA_SPAN_MAX,  FXAA_SPAN_MAX),
            max(vec2(-FXAA_SPAN_MAX, -FXAA_SPAN_MAX),
            dir * rcpDirMin)) / frameBufSize;

      vec3 rgbA = (1.0/2.0) * (
          texture(Texture0, TextureCoordsVarying.xy + dir * (1.0/3.0 - 0.5)).xyz +
          texture(Texture0, TextureCoordsVarying.xy + dir * (2.0/3.0 - 0.5)).xyz);
      vec3 rgbB = rgbA * (1.0/2.0) + (1.0/4.0) * (
          texture(Texture0, TextureCoordsVarying.xy + dir * (0.0/3.0 - 0.5)).xyz +
          texture(Texture0, TextureCoordsVarying.xy + dir * (3.0/3.0 - 0.5)).xyz);
      float lumaB = dot(rgbB, luma);

      if((lumaB < lumaMin) || (lumaB > lumaMax)){
          fragColor.xyz=rgbA;
      }else{
          fragColor.xyz=rgbB;
      }
  }
  """;
}