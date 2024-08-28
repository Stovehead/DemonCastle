shader_type canvas_item;

const int NUM_COLORS = 3;
const float EPSILON = 0.001;

global uniform float SCALABLE_TIME;
uniform vec4 original_palette[NUM_COLORS];
uniform vec4 new_palettes[27];
uniform int num_new_palettes;
uniform float FPS = 60.0;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	vec4 pixelColor = texture(screen_texture, SCREEN_UV);
	int current_palette = int(SCALABLE_TIME*FPS)%num_new_palettes;
	for(int i = 0; i < NUM_COLORS; i++){
		vec4 difference = abs(original_palette[i] - pixelColor);
		if(all(lessThan(difference, vec4(EPSILON)))){
			COLOR = new_palettes[current_palette*NUM_COLORS + i];
			break;
		}
	}
}
