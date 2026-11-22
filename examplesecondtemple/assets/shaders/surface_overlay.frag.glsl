precision mediump float;

// Surface overlay fragment shader.
//
// Tiles a secondary texture over the terrain patch and fades it out near the
// boundary edges so it blends naturally with the surrounding terrain.

uniform sampler2D surfaceTexture;
uniform float     blendStrength; // overall opacity [0, 1]
uniform float     uvScale;       // meshScale / tilingScale
uniform vec2      boundaryHalf;  // boundary half-extents in local units
uniform float     edgeFade;      // fade fraction of boundary [0, 1]

varying vec2 vLocalXZ;

void main() {
  // Tile the texture using local XZ (which scales with the mesh's own scale
  // uniform so the tiling density stays constant in world space).
  vec2 uv = vLocalXZ * uvScale;
  vec4 texColor = texture2D(surfaceTexture, uv);

  // Edge fade: compute how far we are from the boundary as a 0-1 fraction,
  // where 0 = right at the edge and 1 = dead centre.
  float normX  = abs(vLocalXZ.x) / boundaryHalf.x; // 0 at centre, 1 at edge
  float normZ  = abs(vLocalXZ.y) / boundaryHalf.y;
  float edgeT  = 1.0 - max(normX, normZ);           // 0 at edge, 1 at centre

  float edgeAlpha = edgeFade > 0.0
      ? clamp(smoothstep(0.0, edgeFade, edgeT), 0.0, 1.0)
      : 1.0;

  float alpha = texColor.a * blendStrength * edgeAlpha;
  if (alpha < 0.01) discard;

  gl_FragColor = vec4(texColor.rgb, alpha);
}
