shader_type spatial;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D color;
uniform vec2 offset = vec2(0.5, 0.5);

void fragment(){
	vec4 water_noise = texture(noise1, UV + (TIME/100.0 * offset));
	vec4 water_noise2 = texture(noise2, UV + (TIME/105.0 * -offset));
	vec4 water_color = texture(color, UV);
	
	vec3 first_color_out = mix((water_noise * water_noise2 * water_color).rgb, water_noise.rrr, 0.5);
	
	ALBEDO = first_color_out * water_color.rgb;
	NORMAL = water_noise2.rgb;
	
	ROUGHNESS = .4;
	SPECULAR = 0.1;

}
