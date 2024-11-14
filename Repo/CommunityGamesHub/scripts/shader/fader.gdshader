shader_type canvas_item;

void fragment() {
    vec2 fade = vec2(1.0 - abs(UV.x - 0.5) * 2.0, 1.0 - abs(UV.y - 0.5) * 2.0); 
    fade = clamp(fade, 0.0, 1.0);

    COLOR.a *= fade.x * fade.y;
}

