shader_type canvas_item;
render_mode unshaded;
uniform float pixel_step = 1.0;
varying vec4 sprite_tint;
void vertex() { sprite_tint = COLOR; }
void fragment() {
 vec2 size = vec2(textureSize(TEXTURE, 0));
 vec2 pixel = (floor(UV * size / pixel_step) + 0.5) * pixel_step;
 vec4 source = texture(TEXTURE, pixel / size);
 source.a = step(0.9, source.a);
 COLOR = source * sprite_tint;
}
