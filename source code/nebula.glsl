/*AI help coded shader, creates the "starry" effect */
extern float time;
extern vec2 resolution;
extern vec2 player_position; 

// --- simple hash / noise ---
float hash(vec2 p)
{
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p)
{
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) +
           (c - a) * u.y * (1.0 - u.x) +
           (d - b) * u.x * u.y;
}

// fractal noise (nebula body)
float fbm(vec2 p)
{
    float value = 0.0;
    float amp = 0.5;

    for (int i = 0; i < 5; i++)
    {
        value += amp * noise(p);
        p *= 2.0;
        amp *= 0.5;
    }

    return value;
}

// soft star field
float stars(vec2 uv)
{
    vec2 gv = fract(uv * 200.0);
    vec2 id = floor(uv * 200.0);

    float n = hash(id);

    float star = step(0.995, n);
    float shape = smoothstep(0.0, 0.2, 0.4 - length(gv - 0.5));

    return star * shape;
}

vec4 effect(vec4 color, Image tex, vec2 uv, vec2 screen_coords)
{
    vec2 p = screen_coords / resolution.xy;

    vec2 center = vec2(0.5, 0.5);

    // Apply aspect correction
    float aspect = resolution.x / resolution.y;
    p.x *= aspect;
    center.x *= aspect;


    vec2 nebulaScroll = -player_position * 0.000005; 
    vec2 starScroll   = -player_position * 0.00002; 
    // Idle Drift
    float t = time * 0.05;

    // Apply player movement + idle drift to nebula
    vec2 nebulaP = p + nebulaScroll;

    // slow drifting domain warp
    vec2 q = vec2(
        fbm(nebulaP + vec2(0.0, t)),
        fbm(nebulaP + vec2(5.2, t))
    );

    vec2 r = vec2(
        fbm(nebulaP + 3.0 * q + vec2(1.7, 9.2)),
        fbm(nebulaP + 3.0 * q + vec2(8.3, 2.8))
    );

    float nebula = fbm(nebulaP + r * 2.0 + t);

    // Muted nebula colors
    vec3 col1 = vec3(0.02, 0.0, 0.05);
    vec3 col2 = vec3(0.08, 0.0, 0.2);
    vec3 col3 = vec3(0.0, 0.15, 0.25);

    vec3 colorNebula = mix(col1, col2, nebula);
    colorNebula = mix(colorNebula, col3, smoothstep(0.3, 0.8, r.x));
    
    float nebulaIntensity = 0.35; 
    colorNebula *= nebulaIntensity;

    float starField = stars(p + starScroll + t * 0.1);
    vec3 finalColor = colorNebula + starField * 1.5;

    // Corner Vignette
    float distFromCenter = length(p - center);
    float vignette = smoothstep(1.0, 0.1, distFromCenter);
    
    finalColor *= vignette;

    return vec4(finalColor, 1.0);
}