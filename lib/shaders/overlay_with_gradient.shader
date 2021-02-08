shader_type canvas_item;

uniform vec3 color = vec3(1.0,0.0,0.0);

float rand(vec2 coord){
	return coord.y;
}

void fragment() {
	COLOR = vec4(color, rand(UV));
}