shader_type canvas_item;
uniform float radius = 1.0;

void fragment() {
    float dist = length(UV - vec2(0.5));
    float fade = smoothstep(radius, radius - 0.1, dist);
    COLOR.a *= fade;
}
