// Fragment shader for premium gloss effect
// Provides diagonal highlight and subtle color shift

precision mediump float;

uniform vec2 uSize;
uniform float uMotionFactor;
uniform float uTime;

out vec4 fragColor;

void main() {
  vec2 uv = gl_FragCoord.xy / uSize;
  
  // Create diagonal gradient for gloss highlight
  float diagonal = (uv.x + uv.y) * 0.5;
  
  // Add subtle motion-based shimmer
  float shimmer = sin(diagonal * 10.0 + uTime * 2.0) * 0.5 + 0.5;
  
  // Calculate highlight intensity based on position and motion
  float highlight = smoothstep(0.3, 0.7, diagonal);
  highlight = highlight * (0.3 + uMotionFactor * 0.4);
  
  // Add shimmer to highlight
  highlight = highlight + shimmer * 0.1 * uMotionFactor;
  
  // Create subtle color shift (towards white/cyan)
  vec3 baseColor = vec3(1.0, 1.0, 1.0);
  vec3 accentColor = vec3(0.6, 0.9, 1.0); // Light cyan
  
  // Mix colors based on diagonal and motion
  vec3 color = mix(baseColor, accentColor, diagonal * 0.3);
  
  // Apply highlight
  color = color * (1.0 + highlight);
  
  // Output with alpha for blending
  float alpha = highlight * 0.15;
  fragColor = vec4(color, alpha);
}
