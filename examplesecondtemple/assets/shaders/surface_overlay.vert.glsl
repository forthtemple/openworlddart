precision mediump float;

// Surface overlay vertex shader.
//
// Passes local XZ position to the fragment shader so it can:
//   - tile the secondary texture using world-space coordinates
//   - fade the overlay out near the boundary edges
//
// A small Y offset lifts the overlay fractionally above the terrain surface
// to prevent Z-fighting (depth flickering) as the camera moves.

uniform float uvScale;      // meshScale / tilingScale — converts local XZ to UV
uniform vec2  boundaryHalf; // boundary half-extents in local units
uniform float depthNudge;   // small upward local-unit offset to prevent Z-fighting

varying vec2 vLocalXZ;      // position.xz in local units (before mesh scale)

void main() {
  vLocalXZ = position.xz;
  vec3 nudged = vec3(position.x, position.y + depthNudge, position.z);
  gl_Position = projectionMatrix * modelViewMatrix * vec4(nudged, 1.0);
}
