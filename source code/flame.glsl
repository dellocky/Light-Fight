//Handcoded Shader

extern float intensity;// -- extern intensity - As the player moves faster the effect gets stronger
extern float time; // -- exten time - Creates flame effect through sin wave through time
extern float flame_color;// -- extern color -- While the entity is boosting mix a blueish tint into the flame

vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords) {
    vec2 uv = texture_coords;
    float v = 1.0 - uv.y; 
    float wave1 = sin(uv.y * 8.0 + time * 5.0) * 0.12;
    float wave2 = sin(uv.y * 20.0 - time * 8.0) * 0.06;
    float crackle = sin(uv.y * 50.0 + time * 15.0) * 0.02;
    float flame_center = 0.5 + wave1 + wave2 + crackle;
    float dist_from_center = abs(uv.x - flame_center);
    
    float flame_width = 0.25 * smoothstep(0.0, 0.4, v); 
    float shape_mask = smoothstep(flame_width, flame_width - 0.05, dist_from_center);
    vec3 final_color;

    if (flame_color == 0) {
        if (v < 0.3) {
            final_color = mix(vec3(1.0, 0.3, 0.0), vec3(1.0, 0.6, 0.0), v / 0.3);
        } else if (v < 0.7) {
            final_color = mix(vec3(1.0, 0.6, 0.0), vec3(1.0, 0.9, 0.2), (v - 0.3) / 0.4);
        } else {
            final_color = mix(vec3(1.0, 0.9, 0.2), vec3(1.0, 1.0, 1.0), (v - 0.7) / 0.3);
        }
    }

    if (flame_color == 1) {
        if (v < 0.3) {
            final_color = mix(vec3(0.0, 0.3, 1.0),  vec3(1.0, 0.6, 0.0), v / 0.3);
        } else if (v < 0.7) {
            final_color = mix(vec3(0.0, 0.6, 1.0), vec3(1.0, 0.9, 0.2), (v - 0.3) / 0.4);
        } else {
            final_color = mix(vec3(0.2, 0.9, 1.0), vec3(1.0, 1.0, 1.0), (v - 0.7) / 0.3);
        }
    }

    float alpha = shape_mask * smoothstep(0.0, 0.2, v) * intensity;
    return vec4(final_color, alpha) * color;
}