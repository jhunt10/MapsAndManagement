shader_type canvas_item;
render_mode skip_vertex_transform;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

uniform sampler2D image : source_color;

uniform float screen_width = 640.0; // you can assign a default value to uniforms
uniform float screen_hight = 480.0; // you can assign a default value to uniforms

uniform float brightness = 1.0;
uniform float contrast = 1.0;
uniform float saturation = 1.0;

void vertex() {

    VERTEX = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
//	VERTEX += vec2(cos(TIME)*100.0, sin(TIME)*100.0);
}

void fragment() {
//	COLOR = vec4(SCREEN_UV, 0.0, 1.0);
//	COLOR = texture(TEXTURE, vec2(VERTEX.x / screen_width, VERTEX.y / screen_hight));
	COLOR = texture(TEXTURE, UV);
//	COLOR = texture(image, SCREEN_UV);
	
//	vec3 c = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

//    c.rgb = mix(vec3(0.0), c.rgb, brightness);
//    c.rgb = mix(vec3(0.5), c.rgb, contrast);
//    c.rgb = mix(vec3(dot(vec3(1.0), c.rgb) * 0.33333), c.rgb, saturation);

//    COLOR.rgb = c;
}
