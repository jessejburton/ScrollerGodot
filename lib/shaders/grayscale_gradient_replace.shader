shader_type canvas_item;
render_mode unshaded;

uniform sampler2D gradient : hint_black;
uniform float mix_amount = 0;

// fragment() Runs for each pixel
void fragment() {
	vec4 input_color = texture(TEXTURE, UV);
	
	/* 
	*	Thanks GDQuest - https://www.youtube.com/watch?v=i7VljTl4I3w&t=909s
	* 	This is one way to calculate the grayscale value of each pixel
	*/
	//float grayscale_value = dot(input_color.rgb, vec3(0.299,0.587,0.114));
	float grayscale_value = dot(input_color.rgb, vec3(0.299,0.587,0.114));
	vec3 sampled_color = texture(gradient, vec2(grayscale_value, 0.0)).rgb;
	
	COLOR.rgb = mix(input_color.rgb, sampled_color, mix_amount);
	COLOR.a = input_color.a;
}