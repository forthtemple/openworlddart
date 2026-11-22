precision mediump float;
precision mediump int;

// Plant sprites.
// Up to MAX_PLANTS sprite textures are supported.
#define MAX_PLANTS 10
uniform sampler2D plantSprite0;
uniform sampler2D plantSprite1;
uniform sampler2D plantSprite2;
uniform sampler2D plantSprite3;
uniform sampler2D plantSprite4;
uniform sampler2D plantSprite5;
uniform sampler2D plantSprite6;
uniform sampler2D plantSprite7;
uniform sampler2D plantSprite8;
uniform sampler2D plantSprite9;
uniform float plantUseSprite0;
uniform float plantUseSprite1;
uniform float plantUseSprite2;
uniform float plantUseSprite3;
uniform float plantUseSprite4;
uniform float plantUseSprite5;
uniform float plantUseSprite6;
uniform float plantUseSprite7;
uniform float plantUseSprite8;
uniform float plantUseSprite9;

uniform float spriteAlphaThreshold;
uniform float spriteFlipY;   // 1.0 on web, where textures load the other way up
uniform float grassShadow;
uniform vec3 ambientColor;

uniform vec3 fogColor;
uniform float fogNear;
uniform float fogFar;

varying vec2  vCorner;
varying float vType;
varying float vFlipH;
varying float vFade;
varying float vLayerFade;
varying float vFogDepth;

float hash12(vec2 p) {
  vec3 p3 = fract(vec3(p.xyx) * 0.1031);
  p3 += dot(p3, p3.yzx + 33.33);
  return fract((p3.x + p3.y) * p3.z);
}

void main() {
  float spriteX = vFlipH > 0.5 ? 1.0 - vCorner.x : vCorner.x;
  float spriteY = spriteFlipY > 0.5 ? vCorner.y : 1.0 - vCorner.y;
  vec2 spriteUV = vec2(spriteX, spriteY);

  vec4 s = vec4(0.0);
  if (abs(vType - 0.0) < 0.5) {
    if (plantUseSprite0 < 0.5) discard;
    s = texture2D(plantSprite0, spriteUV);
  } else if (abs(vType - 1.0) < 0.5) {
    if (plantUseSprite1 < 0.5) discard;
    s = texture2D(plantSprite1, spriteUV);
  } else if (abs(vType - 2.0) < 0.5) {
    if (plantUseSprite2 < 0.5) discard;
    s = texture2D(plantSprite2, spriteUV);
  } else if (abs(vType - 3.0) < 0.5) {
    if (plantUseSprite3 < 0.5) discard;
    s = texture2D(plantSprite3, spriteUV);
  } else if (abs(vType - 4.0) < 0.5) {
    if (plantUseSprite4 < 0.5) discard;
    s = texture2D(plantSprite4, spriteUV);
  } else if (abs(vType - 5.0) < 0.5) {
    if (plantUseSprite5 < 0.5) discard;
    s = texture2D(plantSprite5, spriteUV);
  } else if (abs(vType - 6.0) < 0.5) {
    if (plantUseSprite6 < 0.5) discard;
    s = texture2D(plantSprite6, spriteUV);
  } else if (abs(vType - 7.0) < 0.5) {
    if (plantUseSprite7 < 0.5) discard;
    s = texture2D(plantSprite7, spriteUV);
  } else if (abs(vType - 8.0) < 0.5) {
    if (plantUseSprite8 < 0.5) discard;
    s = texture2D(plantSprite8, spriteUV);
  } else if (abs(vType - 9.0) < 0.5) {
    if (plantUseSprite9 < 0.5) discard;
    s = texture2D(plantSprite9, spriteUV);
  } else {
    discard;
  }

  if (s.a < spriteAlphaThreshold) discard;

  if (vLayerFade < 1.0) {
    float dither = hash12(gl_FragCoord.xy);
    if (dither > vLayerFade) discard;
  }

  if (vFade < 1.0) {
    float dither = hash12(gl_FragCoord.xy);
    if (dither > vFade) discard;
  }

  float shadow = (1.0 - grassShadow) + vCorner.y * grassShadow;
  gl_FragColor = vec4(s.rgb * shadow * ambientColor, s.a);

  float fogFactor = smoothstep(fogNear, fogFar, vFogDepth);
  gl_FragColor.rgb = mix(gl_FragColor.rgb, fogColor, fogFactor);
}
