shader_type canvas_item;
render_mode blend_mix;

uniform float blur_radius = 2.0;

void fragment() {
	vec4 col = texture(SCREEN_TEXTURE, UV);
	vec2 ps = TEXTURE_PIXEL_SIZE;

	col += texture(SCREEN_TEXTURE, UV + vec2(0.0, -blur_radius) * ps);
	col += texture(SCREEN_TEXTURE, UV + vec2(0.0, blur_radius) * ps);
	col += texture(SCREEN_TEXTURE, UV + vec2(-blur_radius, 0.0) * ps);
	col += texture(SCREEN_TEXTURE, UV + vec2(blur_radius, 0.0) * ps);
	col /= 5.0;

	COLOR = col;
}