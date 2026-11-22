import 'package:flutter_angle/flutter_angle.dart';

class GlProgram {
  late Program program;
  late WebGLShader fragShader, vertShader;

  GlProgram(
    RenderingContext gl,
    String fragSrc, 
    String vertSrc
  ) {
    fragShader = gl.createShader(WebGL.FRAGMENT_SHADER);
    gl.shaderSource(fragShader, fragSrc);
    gl.compileShader(fragShader);

    vertShader = gl.createShader(WebGL.VERTEX_SHADER);
    gl.shaderSource(vertShader, vertSrc);
    gl.compileShader(vertShader);

    program = gl.createProgram();
    gl.attachShader(program, vertShader);
    gl.attachShader(program, fragShader);
    gl.linkProgram(program);

    gl.deleteShader(vertShader);
    gl.deleteShader(fragShader);
  }
}
