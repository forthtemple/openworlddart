// highp: vertex positions are world-scale numbers; mediump (16-bit on
// Apple/mobile GPUs) is too coarse for them. All GLSL ES vertex shaders
// support highp.
precision highp float;
precision highp int;

// Plant quads.
attribute float type;
attribute vec2  corner;
attribute float flipH;
attribute vec2  quadHalfSize;
attribute vec2  quadYaw;
attribute float quadPitch;

#define MAX_PLANTS 10
#define MAX_EXCLUSION_SQUARES 96 //64 //32
#define MAX_PLANT_EXCLUSION_SQUARES 64

varying vec2  vCorner;
varying float vType;
varying float vFlipH;
varying float vFade;
varying float vLayerFade;
varying float vFogDepth;

uniform float iTime;
uniform float windSpeed;
uniform vec2  cameraXZ;
uniform vec2  boundaryHalf;
uniform float edgeFalloff;
uniform float meshScale;
uniform float planeSize;
uniform float layerFadeAngle;
uniform float plantCount;
uniform float plantBillboard0;
uniform float plantBillboard1;
uniform float plantBillboard2;
uniform float plantBillboard3;
uniform float plantBillboard4;
uniform float plantBillboard5;
uniform float plantBillboard6;
uniform float plantBillboard7;
uniform float plantBillboard8;
uniform float plantBillboard9;
uniform float plantPlaneSize0;
uniform float plantPlaneSize1;
uniform float plantPlaneSize2;
uniform float plantPlaneSize3;
uniform float plantPlaneSize4;
uniform float plantPlaneSize5;
uniform float plantPlaneSize6;
uniform float plantPlaneSize7;
uniform float plantPlaneSize8;
uniform float plantPlaneSize9;
uniform float plantEdgeFadeWidth0;
uniform float plantEdgeFadeWidth1;
uniform float plantEdgeFadeWidth2;
uniform float plantEdgeFadeWidth3;
uniform float plantEdgeFadeWidth4;
uniform float plantEdgeFadeWidth5;
uniform float plantEdgeFadeWidth6;
uniform float plantEdgeFadeWidth7;
uniform float plantEdgeFadeWidth8;
uniform float plantEdgeFadeWidth9;
uniform float plantUseFootprintExclusion0;
uniform float plantUseFootprintExclusion1;
uniform float plantUseFootprintExclusion2;
uniform float plantUseFootprintExclusion3;
uniform float plantUseFootprintExclusion4;
uniform float plantUseFootprintExclusion5;
uniform float plantUseFootprintExclusion6;
uniform float plantUseFootprintExclusion7;
uniform float plantUseFootprintExclusion8;
uniform float plantUseFootprintExclusion9;
uniform float plantExclusionOffset0;
uniform float plantExclusionOffset1;
uniform float plantExclusionOffset2;
uniform float plantExclusionOffset3;
uniform float plantExclusionOffset4;
uniform float plantExclusionOffset5;
uniform float plantExclusionOffset6;
uniform float plantExclusionOffset7;
uniform float plantExclusionOffset8;
uniform float plantExclusionOffset9;
uniform float plantExcludeStart0;
uniform float plantExcludeStart1;
uniform float plantExcludeStart2;
uniform float plantExcludeStart3;
uniform float plantExcludeStart4;
uniform float plantExcludeStart5;
uniform float plantExcludeStart6;
uniform float plantExcludeStart7;
uniform float plantExcludeStart8;
uniform float plantExcludeStart9;
uniform float plantExcludeCount0;
uniform float plantExcludeCount1;
uniform float plantExcludeCount2;
uniform float plantExcludeCount3;
uniform float plantExcludeCount4;
uniform float plantExcludeCount5;
uniform float plantExcludeCount6;
uniform float plantExcludeCount7;
uniform float plantExcludeCount8;
uniform float plantExcludeCount9;
uniform float plantScrolling0;
uniform float plantScrolling1;
uniform float plantScrolling2;
uniform float plantScrolling3;
uniform float plantScrolling4;
uniform float plantScrolling5;
uniform float plantScrolling6;
uniform float plantScrolling7;
uniform float plantScrolling8;
uniform float plantScrolling9;
// Terrain heights baked into a texture by Vegetation._bakeHeightMap (height
// in .r, world units). Replaces the old terrainPoints/terrainTri* uniform
// arrays, which needed ~3,800 vertex uniform vectors and failed to link on
// macOS/iOS (limit 1024). highp sampler so the fetched height keeps full
// float precision on mobile GPUs.
uniform highp sampler2D terrainHeightMap;
uniform vec2  heightMapHalf;   // half extents (world units) the map covers
uniform float heightMapRes;    // texels per side
uniform float heightMapValid;  // 0.0 = no terrain data, use height 0
uniform float excludeSquareCount;
uniform vec4 excludeSquares[MAX_EXCLUSION_SQUARES];
uniform vec4 plantExcludeSquares[MAX_PLANT_EXCLUSION_SQUARES]; // xyzw = x, z, width, length in world units

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float plantBillboard(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantBillboard0;
  if (abs(plantType - 1.0) < 0.5) return plantBillboard1;
  if (abs(plantType - 2.0) < 0.5) return plantBillboard2;
  if (abs(plantType - 3.0) < 0.5) return plantBillboard3;
  if (abs(plantType - 4.0) < 0.5) return plantBillboard4;
  if (abs(plantType - 5.0) < 0.5) return plantBillboard5;
  if (abs(plantType - 6.0) < 0.5) return plantBillboard6;
  if (abs(plantType - 7.0) < 0.5) return plantBillboard7;
  if (abs(plantType - 8.0) < 0.5) return plantBillboard8;
  if (abs(plantType - 9.0) < 0.5) return plantBillboard9;
  return 1.0;
}

float plantPlaneSizeFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantPlaneSize0;
  if (abs(plantType - 1.0) < 0.5) return plantPlaneSize1;
  if (abs(plantType - 2.0) < 0.5) return plantPlaneSize2;
  if (abs(plantType - 3.0) < 0.5) return plantPlaneSize3;
  if (abs(plantType - 4.0) < 0.5) return plantPlaneSize4;
  if (abs(plantType - 5.0) < 0.5) return plantPlaneSize5;
  if (abs(plantType - 6.0) < 0.5) return plantPlaneSize6;
  if (abs(plantType - 7.0) < 0.5) return plantPlaneSize7;
  if (abs(plantType - 8.0) < 0.5) return plantPlaneSize8;
  if (abs(plantType - 9.0) < 0.5) return plantPlaneSize9;
  return planeSize;
}

float plantEdgeFadeWidthFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantEdgeFadeWidth0;
  if (abs(plantType - 1.0) < 0.5) return plantEdgeFadeWidth1;
  if (abs(plantType - 2.0) < 0.5) return plantEdgeFadeWidth2;
  if (abs(plantType - 3.0) < 0.5) return plantEdgeFadeWidth3;
  if (abs(plantType - 4.0) < 0.5) return plantEdgeFadeWidth4;
  if (abs(plantType - 5.0) < 0.5) return plantEdgeFadeWidth5;
  if (abs(plantType - 6.0) < 0.5) return plantEdgeFadeWidth6;
  if (abs(plantType - 7.0) < 0.5) return plantEdgeFadeWidth7;
  if (abs(plantType - 8.0) < 0.5) return plantEdgeFadeWidth8;
  if (abs(plantType - 9.0) < 0.5) return plantEdgeFadeWidth9;
  return 0.0;
}

float plantUseFootprintExclusionFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantUseFootprintExclusion0;
  if (abs(plantType - 1.0) < 0.5) return plantUseFootprintExclusion1;
  if (abs(plantType - 2.0) < 0.5) return plantUseFootprintExclusion2;
  if (abs(plantType - 3.0) < 0.5) return plantUseFootprintExclusion3;
  if (abs(plantType - 4.0) < 0.5) return plantUseFootprintExclusion4;
  if (abs(plantType - 5.0) < 0.5) return plantUseFootprintExclusion5;
  if (abs(plantType - 6.0) < 0.5) return plantUseFootprintExclusion6;
  if (abs(plantType - 7.0) < 0.5) return plantUseFootprintExclusion7;
  if (abs(plantType - 8.0) < 0.5) return plantUseFootprintExclusion8;
  if (abs(plantType - 9.0) < 0.5) return plantUseFootprintExclusion9;
  return 0.0;
}

float plantExclusionOffsetFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantExclusionOffset0;
  if (abs(plantType - 1.0) < 0.5) return plantExclusionOffset1;
  if (abs(plantType - 2.0) < 0.5) return plantExclusionOffset2;
  if (abs(plantType - 3.0) < 0.5) return plantExclusionOffset3;
  if (abs(plantType - 4.0) < 0.5) return plantExclusionOffset4;
  if (abs(plantType - 5.0) < 0.5) return plantExclusionOffset5;
  if (abs(plantType - 6.0) < 0.5) return plantExclusionOffset6;
  if (abs(plantType - 7.0) < 0.5) return plantExclusionOffset7;
  if (abs(plantType - 8.0) < 0.5) return plantExclusionOffset8;
  if (abs(plantType - 9.0) < 0.5) return plantExclusionOffset9;
  return 0.0;
}

float plantFootprintRadius(float plantType) {
  float billboard = plantBillboard(plantType);
  if (billboard < 0.5) {
    return max(quadHalfSize.x, quadHalfSize.y) * meshScale;
  }
  return max(quadHalfSize.x * 2.0, quadHalfSize.y) * 0.5 * meshScale;
}

float heightTexel(vec2 ij) {
  // Nearest-filtered texel centre lookup.
  return texture2D(terrainHeightMap, (ij + 0.5) / heightMapRes).r;
}

// Bilinear terrain height lookup. Texel (i, j) holds the height at
// -heightMapHalf + (i, j) * 2*heightMapHalf / (heightMapRes - 1).
// Interpolation is done here rather than with LinearFilter because linear
// filtering of float textures isn't supported on every device (e.g. iOS).
float sampleTerrainHeight(vec2 worldXZ) {
  if (heightMapValid < 0.5) return 0.0;

  float last = heightMapRes - 1.0;
  vec2 g = (worldXZ + heightMapHalf) / (2.0 * heightMapHalf) * last;
  g = clamp(g, vec2(0.0), vec2(last));
  vec2 i0 = floor(g);
  vec2 f  = g - i0;
  vec2 i1 = min(i0 + 1.0, vec2(last));

  float h00 = heightTexel(i0);
  float h10 = heightTexel(vec2(i1.x, i0.y));
  float h01 = heightTexel(vec2(i0.x, i1.y));
  float h11 = heightTexel(i1);
  return mix(mix(h00, h10, f.x), mix(h01, h11, f.x), f.y);
}

float plantExcludeStartFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantExcludeStart0;
  if (abs(plantType - 1.0) < 0.5) return plantExcludeStart1;
  if (abs(plantType - 2.0) < 0.5) return plantExcludeStart2;
  if (abs(plantType - 3.0) < 0.5) return plantExcludeStart3;
  if (abs(plantType - 4.0) < 0.5) return plantExcludeStart4;
  if (abs(plantType - 5.0) < 0.5) return plantExcludeStart5;
  if (abs(plantType - 6.0) < 0.5) return plantExcludeStart6;
  if (abs(plantType - 7.0) < 0.5) return plantExcludeStart7;
  if (abs(plantType - 8.0) < 0.5) return plantExcludeStart8;
  if (abs(plantType - 9.0) < 0.5) return plantExcludeStart9;
  return 0.0;
}

float plantExcludeCountFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantExcludeCount0;
  if (abs(plantType - 1.0) < 0.5) return plantExcludeCount1;
  if (abs(plantType - 2.0) < 0.5) return plantExcludeCount2;
  if (abs(plantType - 3.0) < 0.5) return plantExcludeCount3;
  if (abs(plantType - 4.0) < 0.5) return plantExcludeCount4;
  if (abs(plantType - 5.0) < 0.5) return plantExcludeCount5;
  if (abs(plantType - 6.0) < 0.5) return plantExcludeCount6;
  if (abs(plantType - 7.0) < 0.5) return plantExcludeCount7;
  if (abs(plantType - 8.0) < 0.5) return plantExcludeCount8;
  if (abs(plantType - 9.0) < 0.5) return plantExcludeCount9;
  return 0.0;
}

float plantScrollingFn(float plantType) {
  if (abs(plantType - 0.0) < 0.5) return plantScrolling0;
  if (abs(plantType - 1.0) < 0.5) return plantScrolling1;
  if (abs(plantType - 2.0) < 0.5) return plantScrolling2;
  if (abs(plantType - 3.0) < 0.5) return plantScrolling3;
  if (abs(plantType - 4.0) < 0.5) return plantScrolling4;
  if (abs(plantType - 5.0) < 0.5) return plantScrolling5;
  if (abs(plantType - 6.0) < 0.5) return plantScrolling6;
  if (abs(plantType - 7.0) < 0.5) return plantScrolling7;
  if (abs(plantType - 8.0) < 0.5) return plantScrolling8;
  if (abs(plantType - 9.0) < 0.5) return plantScrolling9;
  return 1.0; // default: scrolling
}


bool isExcluded(vec2 worldXZ, float plantType) {
  float plantRadiusWorld = plantFootprintRadius(plantType);
  float padding = max(0.0, plantExclusionOffsetFn(plantType)) * 0.5;

  // Global exclusion squares (apply to all plants that have useFootprintExclusion).
  for (int i = 0; i < MAX_EXCLUSION_SQUARES; i++) {
    if (float(i) >= excludeSquareCount) break;

    vec4 square = excludeSquares[i];
    vec2 delta = abs(worldXZ - square.xy);
    vec2 halfSize = abs(square.zw) * 0.5 + vec2(padding, padding);
    if (delta.x <= halfSize.x + plantRadiusWorld && delta.y <= halfSize.y + plantRadiusWorld) {
      return true;
    }
  }

  // Per-plant exclusion squares: iterate the slice [pStart, pStart+pCount) of
  // the flat plantExcludeSquares array.  We use float comparisons against the
  // loop variable to stay GLSL ES 1.0 compatible (no dynamic array indexing).
  float pStart = plantExcludeStartFn(plantType);
  float pCount = plantExcludeCountFn(plantType);
  if (pCount > 0.0) {
    for (int i = 0; i < MAX_PLANT_EXCLUSION_SQUARES; i++) {
      float fi = float(i);
      if (fi < pStart) continue;
      if (fi >= pStart + pCount) break;

      vec4 square = plantExcludeSquares[i];
      vec2 delta = abs(worldXZ - square.xy);
      vec2 halfSize = abs(square.zw) * 0.5;
      if (delta.x <= halfSize.x + plantRadiusWorld && delta.y <= halfSize.y + plantRadiusWorld) {
        return true;
      }
    }
  }

  return false;
}

void main() {
  vCorner = corner;
  vType   = type;
  vFlipH  = flipH;
  vLayerFade = 1.0;

  float myPlaneSize = plantPlaneSizeFn(type);

  vec2  cameraLocal   = cameraXZ     / meshScale;
  vec2  boundaryLocal = boundaryHalf / meshScale;
  float falloffLocal  = edgeFalloff  / meshScale;

  float halfSize = myPlaneSize * 0.5;
  float cx = uv.x;
  float cz = uv.y;

  // Scrolling plants tile via mod() so the fixed set of instances follows the
  // camera continuously.  Static plants (scrolling == 0) use their scatter
  // position directly — they are always at a fixed location within the boundary.
  float wrappedCX;
  float wrappedCZ;
  if (plantScrollingFn(type) > 0.5) {
    wrappedCX = cameraLocal.x + (mod(cx - cameraLocal.x + halfSize, myPlaneSize) - halfSize);
    wrappedCZ = cameraLocal.y + (mod(cz - cameraLocal.y + halfSize, myPlaneSize) - halfSize);
  } else {
    wrappedCX = cx;
    wrappedCZ = cz;
  }
  vec2 wrappedWorldXZ = vec2(wrappedCX, wrappedCZ) * meshScale;

  // Always call isExcluded when either the global or the per-plant exclusion
  // squares are active for this plant type.
  bool globalExclusionActive = plantUseFootprintExclusionFn(type) > 0.5 ||
                               abs(plantExclusionOffsetFn(type)) > 0.000001;
  bool plantExclusionActive  = plantExcludeCountFn(type) > 0.0;
  if ((globalExclusionActive || plantExclusionActive) &&
      isExcluded(wrappedWorldXZ, type)) {
    gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
    return;
  }

  float terrainHeightLocal = meshScale > 0.0
      ? sampleTerrainHeight(wrappedWorldXZ) / meshScale
      : 0.0;

  // ── Hard boundary cull ────────────────────────────────────────────────────
  if (abs(wrappedCX) > boundaryLocal.x || abs(wrappedCZ) > boundaryLocal.y) {
    gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
    return;
  }

  // ── Edge density falloff ──────────────────────────────────────────────────
  if (falloffLocal > 0.0) {
    float distX   = boundaryLocal.x - abs(wrappedCX);
    float distZ   = boundaryLocal.y - abs(wrappedCZ);
    float minDist = min(distX, distZ);
    float t       = clamp(minDist / falloffLocal, 0.0, 1.0);
    float r       = hash(vec2(cx + 7.3, cz + 3.1));
    if (r > t) {
      gl_Position = vec4(2.0, 2.0, 2.0, 1.0);
      return;
    }
  }

  float uvX = (wrappedCX - cameraLocal.x) / planeSize + 0.5;
  float edgeFadeWidth = plantEdgeFadeWidthFn(type);
  float edgeFade = 1.0;

  if (edgeFadeWidth > 0.0) {
    float halfTile = myPlaneSize * 0.5;
    float localX = wrappedCX - cameraLocal.x;
    float localZ = wrappedCZ - cameraLocal.y;
    float distToEdge = min(halfTile - abs(localX), halfTile - abs(localZ));
    edgeFade = clamp(smoothstep(0.0, edgeFadeWidth, distToEdge), 0.0, 1.0);
  }

  vec3 centre = vec3(position.x + (wrappedCX - cx),
                     position.y + terrainHeightLocal,
                     position.z + (wrappedCZ - cz));

  vec3 finalPos;
  float billboard = plantBillboard(type);
  vFade = edgeFade;

  if (billboard < 0.5) {
    vec3 yawDir  = vec3(quadYaw.x, 0.0, quadYaw.y);
    vec3 perpDir = vec3(-quadYaw.y, 0.0, quadYaw.x);
    float alongOffset = (corner.x - 0.5) * 2.0 * quadHalfSize.x;
    float perpOffset  = (corner.y - 0.5) * 2.0 * quadHalfSize.y;
    finalPos = centre + yawDir * alongOffset + perpDir * perpOffset;

  } else if (billboard > 2.5 && billboard < 3.5) {
    vec3 yawDir  = vec3(quadYaw.x, 0.0, quadYaw.y);
    vec3 forwardDir = normalize(vec3(quadYaw.x, 0.0, quadYaw.y));
    vec3 upDir   = vec3(0.0, 1.0, 0.0);
    float offsetH = (corner.x - 0.5) * 2.0 * quadHalfSize.x;
    float offsetV = corner.y * quadHalfSize.y;
    if (layerFadeAngle > 0.0) {
      vec2 toCam2D = vec2(cameraLocal.x - wrappedCX, cameraLocal.y - wrappedCZ);
      float camDist = length(toCam2D);
      if (camDist > 0.001) {
        vec2 camDir = toCam2D / camDist;
        vec2 planeDir = normalize(quadYaw);
        float faceFactor = 1.0 - abs(dot(planeDir, camDir));
        vLayerFade = smoothstep(0.0, layerFadeAngle, faceFactor);
      }
    }
    float pitchOffset = offsetV * tan(quadPitch);
    finalPos = centre + yawDir * offsetH + upDir * offsetV + forwardDir * pitchOffset;

  } else if (billboard < 1.5) {
    vec2 toCam2D = vec2(cameraLocal.x - wrappedCX, cameraLocal.y - wrappedCZ);
    float camDist = length(toCam2D);
    vec2 toCamN  = camDist > 0.001 ? toCam2D / camDist : vec2(0.0, 1.0);
    vec3 billRight = vec3(-toCamN.y, 0.0, toCamN.x);
    float offsetH = (corner.x - 0.5) * 2.0 * quadHalfSize.x;
    float offsetV = corner.y * quadHalfSize.y;
    finalPos = centre + billRight * offsetH + vec3(0.0, offsetV, 0.0);

  } else {
    vec3 cameraRight = normalize(vec3(
        modelViewMatrix[0][0], modelViewMatrix[1][0], modelViewMatrix[2][0]));
    vec3 cameraUp = normalize(vec3(
        modelViewMatrix[0][1], modelViewMatrix[1][1], modelViewMatrix[2][1]));
    float offsetH = (corner.x - 0.5) * 2.0 * quadHalfSize.x;
    float offsetV = corner.y * quadHalfSize.y;
    finalPos = centre + cameraRight * offsetH + cameraUp * offsetV;
  }

  if (billboard > 0.5 && billboard < 1.5 && windSpeed > 0.0 && corner.y > 0.0) {
    float wave = sin((iTime / 500.0) + (uvX * 10.0)) * windSpeed;
    finalPos.x += wave * corner.y * 0.3;  // tip sway distance
  }

  vec4 mvPosition = modelViewMatrix * vec4(finalPos, 1.0);
  vFogDepth = -mvPosition.z;
  gl_Position = projectionMatrix * mvPosition;
}
