shader_type canvas_item;

uniform vec2 speed = vec2(0.0, -1.0);
uniform float anchor : hint_range(-1.0,1.0) = -0.5;
uniform float fov : hint_range(0.01, 1.0) = 0.2;

void fragment() {
	vec2 uv = UV;
    uv.y = 5.0 / (abs(uv.y + fov) + 0.1);
	uv.x += anchor;
    uv.x *= uv.y * 1.0;
	COLOR = texture(TEXTURE, mod(UV + TIME * speed, 1.0));
}