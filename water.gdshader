shader_type spatial;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D color;
uniform vec2 offset = vec2(0.5, 0.5);

void fragment(){
	vec4 water_noise = texture(noise1, UV + (TIME/100.0 * offset));
	vec4 water_noise2 = texture(noise2, UV + (TIME/105.0 * offset));
	vec4 water_color = texture(color, UV);
		
	//ALBEDO = (water_noise * water_noise2 * water_color).rgb;
	ALBEDO = mix(water_noise.rrr* water_noise2.r, water_color.rgb, 0.8);
	
	ROUGHNESS = .1;
	SPECULAR = 1.0;

}
