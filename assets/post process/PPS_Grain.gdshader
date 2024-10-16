shader_type canvas_item;

// Uniforms
uniform sampler2D screen_texture : hint_screen_texture; // The screen texture to sample from
uniform float grain_amount : hint_range(0.0, 1.0) = 0.1; // Amount of grain
uniform float grain_size : hint_range(1.0, 100.0) = 80.0; // Size of the grain, increased for visibility
uniform float distortion_strength : hint_range(0.0, 1.0) = 0.05; // Strength of the lens distortion
uniform float chromatic_aberration_strength : hint_range(0.0, 0.01) = 0.001; // Strength for color separation
uniform float aberration_radius : hint_range(0.0, 1.0) = 0.4; // Radius for chromatic aberration effect

uniform float speed = 0.5; // Primarily for toggling time dependance on and off

// Simple animated noise function
float noise(vec2 uv, float time) {
    // Increase frequency of noise by adjusting the UV scale
    return fract(sin(dot(uv * 0.1, vec2(12.9898, 78.233) + time * speed)) * 43758.5453);
}

void fragment() {
    // Sample the original screen texture
    vec4 original_color = texture(screen_texture, SCREEN_UV);

    // Calculate the UV coordinates based on the fragment position
    vec2 uv = SCREEN_UV;

    // Calculate the center of the rect (0.5, 0.5)
    vec2 center = vec2(0.5);

    // Compute the distance from the center
    vec2 to_center = uv - center;
    float dist = length(to_center);

    // Apply lens distortion based on the distance from the center
    float radius = 1.0 - smoothstep(0.0, 0.5, dist); // Controls the transition for distortion
    vec2 distorted_uv = uv + to_center * (distortion_strength * dist * radius);

    // Determine the effect of chromatic aberration based on distance from center
    float effect_amount = smoothstep(aberration_radius, 1.0, dist);

    // Calculate noise displacement for chromatic aberration
    float noise_displacement = noise(uv * 0.5, TIME) * 0.001; // Scale the noise for the displacement

    // Sample the original color for chromatic aberration with noise displacement
    vec4 aberrated_color = vec4(
        texture(screen_texture, distorted_uv + vec2(-chromatic_aberration_strength * dist * effect_amount + noise_displacement, 0.0)).r, // Red channel
        texture(screen_texture, distorted_uv).g, // Green channel
        texture(screen_texture, distorted_uv + vec2(chromatic_aberration_strength * dist * effect_amount - noise_displacement, 0.0)).b, // Blue channel
        original_color.a // Preserve original alpha
    );

    // Compute the final color before adding noise
    vec3 final_color = aberrated_color.rgb;

    // Generate animated random noise for film grain
    // Scale UVs for tiling the noise
    vec2 noise_uv = SCREEN_UV * grain_size; // Scale UV for grain size
    float noise_value = noise(noise_uv, TIME); // Use the noise function with time

    // Increase noise visibility by scaling the grain
    noise_value *= grain_amount * 5.0; // Amplify noise for better visibility

    // Add noise to the final color
    final_color += noise_value; // Directly add the noise value

    // Clamp the final color to ensure it stays in the valid range
    final_color = clamp(final_color, 0.0, 1.0);

    // Output the final color while preserving the original alpha
    COLOR = vec4(final_color, original_color.a);
}
