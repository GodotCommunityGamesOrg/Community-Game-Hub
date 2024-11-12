shader_type canvas_item;
uniform float radius = 1.0;

void fragment() {
    // Calculate the distance from the center of the UV (0.5, 0.5).
    float dist = length(UV - vec2(0.5));

    // Use smoothstep to create a radial fade based on the distance.
    float fade = smoothstep(radius, radius - 0.1, dist); // Adjust 0.1 for softness.

    // Apply the fade effect to the alpha channel.
    COLOR.a *= fade;
}
