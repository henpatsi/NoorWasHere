shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;
uniform sampler2D distort_noise: repeat_enable;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec2 distort_uv = UV + vec2(0.1, 0.1) * TIME;
	vec2 distorted_screen_uv = SCREEN_UV + texture(distort_noise, distort_uv).r * 0.01;
	vec4 screen_color = texture(SCREEN_TEXTURE, distorted_screen_uv);
	COLOR = screen_color;
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
