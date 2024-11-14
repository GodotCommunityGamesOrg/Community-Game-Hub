shader_type canvas_item;


void fragment() {
	COLOR.a -= UV.x-0.5;
}
