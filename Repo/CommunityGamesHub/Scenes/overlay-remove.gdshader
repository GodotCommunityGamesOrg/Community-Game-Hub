shader_type canvas_item;

// Overlay color as RGBA with alpha channel for transparency
uniform vec4 overlay_color : source_color;

// Screen texture to sample the final color after the overlay has been applied
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    // Sample the final observed color from the screen texture
    vec4 final_color = textureLod(screen_texture, SCREEN_UV, 0.0);

    // If overlay is fully opaque, we cannot retrieve the original background color
    if (overlay_color.a >= 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0); // Fallback color (black with full opacity)
    } else {
        // Calculate the background color based on overlay transparency
        vec3 background_color = (final_color.rgb - (overlay_color.a * overlay_color.rgb)) / (1.0 - overlay_color.a);

        // Output the calculated background color as fully opaque
        COLOR = vec4(background_color, 1.0);
    }
}
