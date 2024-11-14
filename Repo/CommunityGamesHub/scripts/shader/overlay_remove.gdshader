shader_type canvas_item;
uniform vec4 overlay_color : source_color;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
    vec4 final_color = textureLod(screen_texture, SCREEN_UV, 0.0);
    if (overlay_color.a >= 1.0) {
        COLOR = vec4(0.0, 0.0, 0.0, 1.0);
    } else {
        vec3 background_color = (final_color.rgb - (overlay_color.a * overlay_color.rgb)) / (1.0 - overlay_color.a);
        COLOR = vec4(background_color, 1.0);
    }
}
