shader_type spatial;
render_mode unshaded;

uniform sampler2D screen_tex : hint_screen_texture;
uniform vec2 pixel_size = vec2(50.0, 50.0); // higher = chunkier pixelation
uniform float blur_strength = 2.0;
uniform vec3 censor_center = vec3(0.0, 0.0, 0.0);
uniform float censor_radius = 2.0;

varying vec3 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // check distance in world space
    float dist = distance(world_pos, censor_center);

    if (dist < censor_radius) {
        // Pixelation
        vec2 pixel_uv = floor(uv * pixel_size) / pixel_size;

        // Blur by sampling neighbors
        vec4 col = vec4(0.0);
        float count = 0.0;
        for (float x = -blur_strength; x <= blur_strength; x++) {
            for (float y = -blur_strength; y <= blur_strength; y++) {
                vec2 offset = vec2(x, y) / (pixel_size * 2.0);
                col += texture(screen_tex, pixel_uv + offset);
                count += 1.0;
            }
        }
        col /= count;

        ALBEDO = col.rgb;
    } else {
        ALBEDO = texture(screen_tex, uv).rgb;
    }
}
