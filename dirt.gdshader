shader_type spatial;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D color;

void fragment(){
	vec4 dirt_noise = texture(noise1, UV);
	vec4 dirt_color = texture(color, UV);
		
	ALBEDO = (dirt_color * dirt_noise.r).rgb;
}