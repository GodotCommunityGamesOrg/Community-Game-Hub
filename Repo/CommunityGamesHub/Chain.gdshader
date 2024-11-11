shader_type canvas_item;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
void fragment() {
	vec2 fade = vec2(1.0 - abs(UV.x - 0.5) * 2.0, 1.0 - abs(UV.y - 0.5) * 2.0); // Apply the same operation for both axes.
    fade = clamp(fade, 0.0, 1.0); // Clamp to avoid negative alpha.
	if (mod(UV.y * 50.0, 2.0) < 0.1 || mod(UV.x * 50.0, 2.0) < 0.1)
	{
		COLOR = textureLod(screen_texture, SCREEN_UV, 0.0)*fade.x*fade.y;
	}
	else COLOR.a = 0.0;
}
