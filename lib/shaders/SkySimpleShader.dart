//import 'package:three_dart/three3d/math/index.dart';
import 'package:openworld/three_dart/three_dart.dart' as THREE;

Map<String, dynamic> SkySimpleShader = {
  //"shaderID": 'skySimpleShader',
  "uniforms": {
    'topColor': { 'value': THREE.Color.fromHex( 0x88AABB ) },
    'bottomColor': { 'value': THREE.Color.fromHex( 0x00ff00)},//0xEFCB7F ) },
    'offset': { 'value': 300 },//730
    'exponent': { 'value': 0.3 }
  },
  "vertexShader": [
    'varying vec3 vWorldPosition;',
    'void main() {',
    'vec4 worldPosition = modelMatrix * vec4( position, 1.0 );',
    'vWorldPosition = worldPosition.xyz;',
    'gl_Position = projectionMatrix * modelViewMatrix * vec4( position, 1.0 );',
    '}'

  ].join('\n'),
  "fragmentShader": [
    'uniform vec3 topColor;',
    'uniform vec3 bottomColor;',
    'uniform float offset;',
    'uniform float exponent;',
    'varying vec3 vWorldPosition;',
    'void main() {',
    'float h = normalize( vWorldPosition + offset ).y;',
    'gl_FragColor = vec4( mix( bottomColor, topColor, max( pow( max( h , 0.0), exponent ), 0.0 ) ), 1.0 );',
    '}'

  ].join('\n')

};
