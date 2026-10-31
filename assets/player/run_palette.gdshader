shader_type canvas_item;

// Match the original body's olive midtones while retaining steel and cyan.
void fragment() {
	float olive = step(COLOR.r * 1.05, COLOR.g) * step(COLOR.b * 1.5, COLOR.g);
	COLOR.rgb *= mix(vec3(1.0), vec3(0.856, 0.870, 0.914), olive);
}
