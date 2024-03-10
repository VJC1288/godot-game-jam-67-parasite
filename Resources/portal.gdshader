shader_type spatial;

uniform sampler2D noise1: repeat_enable;
uniform sampler2D noise2: repeat_enable;
uniform sampler2D noise3: repeat_enable;
uniform sampler2D color_gradient;
uniform vec2 offset_scroll = vec2(0.5, 0.5);

void fragment() {
	vec4 noise1_color = texture(noise1, UV + (TIME/10.0 * offset_scroll));
	vec4 noise2_color = texture(noise2, UV + (TIME/10.0 * -offset_scroll));
	vec4 noise3_color = texture(noise3, UV + (TIME/100.0 / offset_scroll));
	vec4 portal_color = texture(color_gradient, UV);
	
	
	vec3 out_color = vec3(noise1_color.r * noise2_color.r * noise3_color.r);
	ALBEDO = out_color * portal_color.rgb;
	
}

