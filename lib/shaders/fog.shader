shader_type canvas_item;

uniform vec4 color : hint_color;
uniform int octaves = 2;
uniform float noise_size = 20.0;

const float rand_size = 100.0;

float rand(vec2 coord){
	// fract() returns the decimal value i.e. 0.25 when given 5.25
	return fract(sin(dot(coord, vec2(12,42)) * rand_size) * rand_size);
}

float noise(vec2 coord){
	vec2 i = floor(coord);
	vec2 f = fract(coord);
	
	float a = rand(i);
	float b = rand(i + vec2(1.0,0.0));
	float c = rand(i + vec2(0.0,1.0));
	float d = rand(i + vec2(1.0,1.0));
	
	vec2 cubic = f * f * (3.0 - 2.0 * f);
	
	float value = mix(a,b,cubic.x) + (c - a) * cubic.y * (1.0 - cubic.x) + (d - b) * cubic.x * cubic.y;
	
	return value;
}

// Fractal Brownian Motion
float fbm(vec2 coord){
	float value = 0.0;
	float scale = 0.5;
	
	for(int i = 0; i < octaves; i++){
		value += noise(coord) * scale;
		coord *= 2.0;
		scale *= 0.5;
	}
	
	return value;
}

void fragment() {
	vec2 coord = UV * noise_size;
	
	vec2 motion = vec2(fbm(coord + TIME * 0.5));
	
	float final = fbm(coord + motion);
	
	COLOR = vec4(color.rgb, final * color.a);
}