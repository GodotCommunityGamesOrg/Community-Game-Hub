shader_type canvas_item;


void fragment() {
	COLOR.a -= UV.x-0.5;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
