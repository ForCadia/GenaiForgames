shader_type canvas_item;
render_mode unshaded;
void fragment() {
 vec4 tex = texture(TEXTURE, UV);
 float brightness = max(tex.r, max(tex.g, tex.b));
 COLOR.a *= smoothstep(0.025, 0.14, brightness);
}
