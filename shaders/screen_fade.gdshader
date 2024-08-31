shader_type canvas_item;

const int NUM_COLORS = 53;
const float EPSILON = 0.001;

global uniform float SCALABLE_TIME;
global uniform float ROLLOVER_TIME;
uniform sampler2D palette : filter_nearest;
uniform float start_time = 0.0;
uniform float fade_length = 1;
uniform bool backwards = false;
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {
	float offset = 0.0;
	if(SCALABLE_TIME < start_time - 0.1){
		offset = ROLLOVER_TIME;
	}
	vec4 pixelColor = texture(screen_texture, SCREEN_UV);
	for(int i = 0; i < NUM_COLORS; i++){
		float colorCoordinate = float(i)/float(NUM_COLORS) + EPSILON;
		vec4 colorToCompare = texture(palette, vec2(colorCoordinate, 0));
		vec4 difference = abs(pixelColor - colorToCompare);
		if(all(lessThan(difference, vec4(EPSILON)))){
			float newColorCoordinate = (SCALABLE_TIME - start_time + offset)/fade_length;
			if(backwards) newColorCoordinate = 1.0 - newColorCoordinate;
			COLOR = texture(palette, vec2(colorCoordinate, newColorCoordinate));
			break;
		}
	}
}
