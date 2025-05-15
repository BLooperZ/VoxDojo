shader_type canvas_item;

uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;
uniform vec3 tint : source_color;
uniform float hair_length = 0.015;
uniform float fiber_stretch = 0.05;
uniform float time_scale = 0.002;

uniform vec2 light_direction = vec2(0.6, 0.4); // Adjust for lighting angle
uniform float shadow_strength = 0.7;
uniform float outline_strength = 0.3; // Controls outline intensity

void fragment() {
    vec2 uv = UV;
    
    // Sample noise textures
    float noise1_value = texture(noise1, uv).r - 0.5;
    float noise2_value = texture(noise2, uv).r - 0.5;
    float mixed_noise = noise1_value * noise2_value * 2.0;

    // Stretch noise into directional fibers
    vec2 fiber_offset = vec2(noise1_value, noise2_value) * fiber_stretch;

    // Original texture distortion
    vec2 base_offset = vec2(0.1, 0.1) * mixed_noise;
    
    // Sample base texture with fiber stretching
    vec4 base_color = texture(TEXTURE, uv + base_offset + fiber_offset);

    // Edge detection for extra fuzz
    float edge_factor = smoothstep(0.3, 0.6, base_color.a);
    
    // Generate edge hairs
    vec2 hair_offset = vec2(noise1_value, noise2_value) * hair_length * edge_factor;
    
    // Final base texture output
    vec3 final_color = texture(TEXTURE, uv + base_offset + fiber_offset + hair_offset).rgb;
    final_color = 0.09 * (1.0 - base_color.a) + tint * 0.5 * (noise1_value + 0.8);

    // **Outline Calculation**
    vec3 outline_color = tint * 0.4;  // Slightly darker shade
    float outline_factor = smoothstep(0.1, 0.6, base_color.a) * outline_strength;

    // Blend outline **without overriding base texture**
    final_color = mix(final_color, outline_color, outline_factor);

    COLOR = vec4(final_color, base_color.a * (1.0 + edge_factor * 0.2)); // Preserve fuzz & outline
	
	// **UV-Based Shadow Calculation**
    float shadow_factor = dot((0.2 * (1.0 - SCREEN_UV) + 0.6 * uv), light_direction); // Light direction influence
    shadow_factor = smoothstep(0.2, 0.8, shadow_factor) * shadow_strength; // Control transition


    COLOR.rgb += tint * (0.5 + 0.4 * mixed_noise - shadow_factor);; // Soft alpha extension for fuzzy edges
}