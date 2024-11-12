shader_type canvas_item;

void fragment() {
    // Calculate the distance from the center (0.5) in UV space, then apply a smoothstep.
    vec2 fade = vec2(1.0 - abs(UV.x - 0.5) * 2.0, 1.0 - abs(UV.y - 0.5) * 2.0); // Apply the same operation for both axes.
    fade = clamp(fade, 0.0, 1.0); // Clamp to avoid negative alpha.

    COLOR.a *= fade.x * fade.y; // Apply the fade effect to the alpha.
}

