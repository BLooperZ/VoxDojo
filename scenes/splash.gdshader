shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D noise1 : repeat_enable;
uniform sampler2D noise2 : repeat_enable;

void fragment() {
    COLOR = textureLod(screen_texture, SCREEN_UV, 0.0);
	COLOR.rgb = mix(COLOR.rgb, texture(noise1, vec2(SCREEN_UV.x + sin(0.5 * TIME), SCREEN_UV.y)).rgb, 0.1 * cos(TIME * 2.0));
	COLOR.rgb = mix(COLOR.rgb, texture(noise2, vec2(SCREEN_UV.x, SCREEN_UV.y + cos(0.2 * TIME))).rgb, 0.1 * cos(TIME * 2.0));
	//COLOR = vec4(1.0, 1.0, 1.0, 1.0);
}