shader_type canvas_item;

render_mode blend_mul;

uniform vec2 speed = vec2(0.0, -1.0);

void fragment() {
	COLOR = texture(TEXTURE, mod(UV + TIME * speed, 1.0));
}