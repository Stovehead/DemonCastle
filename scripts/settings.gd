extends Node

const RESOLUTION:Vector2i = Vector2i(384, 216)

signal language_changed
signal fullscreen_changed
signal settings_reset

@onready var font:Font = preload("res://media/fonts/CastlevaniaNES.otf")

var has_unsaved_changes:bool = false
var initialized:bool = false

var current_language:String = "en":
	set(new_language):
		if(new_language != current_language):
			current_language = new_language
			if(initialized):
				has_unsaved_changes = true
			language_changed.emit()
var music_volume_percentage:float = 100.0:
	set(new_music_volume_percentage):
		if(new_music_volume_percentage != music_volume_percentage):
			music_volume_percentage = new_music_volume_percentage
			if(initialized):
				has_unsaved_changes = true
		if(!is_instance_valid(Globals.game_instance) || !is_instance_valid(Globals.game_instance.music_player)):
			return
		Globals.game_instance.music_player.volume_linear = music_volume_percentage/100.0
var sfx_volume_percentage:float = 100.0:
	set(new_sfx_volume_percentage):
		if(new_sfx_volume_percentage != sfx_volume_percentage):
			sfx_volume_percentage = new_sfx_volume_percentage
			if(initialized):
				has_unsaved_changes = true
var window_scale:int = 3:
	set(new_window_scale):
		if(!is_fullscreen):
			var window_position:Vector2 = get_window().position
			get_window().size = RESOLUTION * new_window_scale
			window_position.x -= (RESOLUTION.x * new_window_scale - RESOLUTION.x * window_scale)/2
			window_position.y -= (RESOLUTION.y * new_window_scale - RESOLUTION.y * window_scale)/2
			get_window().position = window_position
		if(new_window_scale != window_scale):
			window_scale = new_window_scale
			if(initialized):
				has_unsaved_changes = true
var is_fullscreen:bool = false:
	set(new_is_fullscreen):
		if(new_is_fullscreen != is_fullscreen):
			is_fullscreen = new_is_fullscreen
			if(initialized):
				has_unsaved_changes = true
		if(new_is_fullscreen):
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			get_window().size = RESOLUTION * window_scale
		fullscreen_changed.emit()
var force_integer_scaling:bool = false:
	set(new_force_integer_scaling):
		if(new_force_integer_scaling != force_integer_scaling):
			force_integer_scaling = new_force_integer_scaling
			if(initialized):
				has_unsaved_changes = true
		if(new_force_integer_scaling):
			get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_INTEGER
		else:
			get_window().content_scale_stretch = Window.CONTENT_SCALE_STRETCH_FRACTIONAL
var subweapon_with_up:bool = true:
	set(new_subweapon_with_up):
		if(new_subweapon_with_up != subweapon_with_up):
			subweapon_with_up = new_subweapon_with_up
			if(initialized):
				has_unsaved_changes = true

var default_keyboard_mappings:Dictionary = {
	"up": KEY_UP,
	"down": KEY_DOWN,
	"left": KEY_LEFT,
	"right": KEY_RIGHT,
	"jump": KEY_Z,
	"attack": KEY_X,
	"crouch": KEY_DOWN,
	"subweapon": KEY_NONE,
	"start": KEY_ENTER,
	"debug": KEY_SHIFT,
	"accept": KEY_Z,
	"cancel": KEY_X,
	"fullscreen": KEY_F11,
	"ui_up": KEY_UP,
	"ui_down": KEY_DOWN,
	"ui_left": KEY_LEFT,
	"ui_right": KEY_RIGHT,
	"ui_accept": KEY_ENTER,
	"ui_cancel": KEY_ESCAPE,
	"a": KEY_A,
	"b": KEY_B,
}

var keyboard_mappings:Dictionary = {
	"up": 0,
	"down": 0,
	"left": 0,
	"right": 0,
	"jump": 0,
	"attack": 0,
	"crouch": 0,
	"subweapon": 0,
	"start": 0,
	"debug": 0,
	"accept": 0,
	"cancel": 0,
	"fullscreen": 0,
	"ui_up": 0,
	"ui_down": 0,
	"ui_left": 0,
	"ui_right": 0,
	"ui_accept": 0,
	"ui_cancel": 0,
	"a": 0,
	"b": 0,
}

var new_keyboard_mappings:Dictionary = {
	"up": 0,
	"down": 0,
	"left": 0,
	"right": 0,
	"jump": 0,
	"attack": 0,
	"crouch": 0,
	"subweapon": 0,
	"start": 0,
	"debug": 0,
	"accept": 0,
	"cancel": 0,
	"fullscreen": 0,
}

func copy_mappings(source:Dictionary, destination:Dictionary) -> void:
	for key in source:
		if(destination.has(key)):
			destination[key] = source[key]

func reset_keyboard_mappings() -> void:
	copy_mappings(default_keyboard_mappings, keyboard_mappings)
	copy_mappings(default_keyboard_mappings, new_keyboard_mappings)
	update_input_map()

func initialize_mappings() -> void:
	copy_mappings(default_keyboard_mappings, keyboard_mappings)
	copy_mappings(default_keyboard_mappings, new_keyboard_mappings)
	update_input_map()

func update_input_map() -> void:
	for action in InputMap.get_actions():
		InputMap.action_erase_events(action)
	for key in keyboard_mappings:
		var new_input_event:InputEventKey = InputEventKey.new()
		new_input_event.keycode = keyboard_mappings[key]
		InputMap.action_add_event(key, new_input_event)
		Input.action_release(key)

func set_language_from_system() -> void:
	if(OS.get_locale() == "ja_JP"):
		current_language = "jp"

func reset_settings() -> void:
	music_volume_percentage = 100.0
	sfx_volume_percentage = 100.0
	window_scale = 3
	is_fullscreen = false
	force_integer_scaling = false
	subweapon_with_up = true
	initialize_mappings()
	settings_reset.emit()

func save_settings() -> void:
	var save_dict:Dictionary = {
		"current_language": current_language,
		"music_volume_percentage": music_volume_percentage,
		"sfx_volume_percentage": sfx_volume_percentage,
		"window_scale": window_scale,
		"is_fullscreen": is_fullscreen,
		"force_integer_scaling": force_integer_scaling,
		"subweapon_with_up": subweapon_with_up,
		"up_key": keyboard_mappings["up"],
		"down_key": keyboard_mappings["down"],
		"left_key": keyboard_mappings["left"],
		"right_key": keyboard_mappings["right"],
		"jump_key": keyboard_mappings["jump"],
		"attack_key": keyboard_mappings["attack"],
		"crouch_key": keyboard_mappings["crouch"],
		"subweapon_key": keyboard_mappings["subweapon"],
		"start_key": keyboard_mappings["start"],
		"debug_key": keyboard_mappings["debug"],
		"accept_key": keyboard_mappings["accept"],
		"cancel_key": keyboard_mappings["cancel"],
		"fullscreen_key": keyboard_mappings["fullscreen"],
		"ui_up_key": keyboard_mappings["ui_up"],
		"ui_down_key": keyboard_mappings["ui_down"],
		"ui_left_key": keyboard_mappings["ui_left"],
		"ui_right_key": keyboard_mappings["ui_right"],
		"ui_accept_key": keyboard_mappings["ui_accept"],
		"ui_cancel_key": keyboard_mappings["ui_cancel"],
		"a_key": keyboard_mappings["a"],
		"b_key": keyboard_mappings["b"],
	}
	var save_file:FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	var json_string:String = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	has_unsaved_changes = false

func load_settings() -> void:
	if(!FileAccess.file_exists("user://settings.save")):
		set_language_from_system()
		initialize_mappings()
		initialized = true
		return 
	var save_file:FileAccess = FileAccess.open("user://settings.save", FileAccess.READ)
	while(save_file.get_position() < save_file.get_length()):
		var json_string:String = save_file.get_line()
		var json:JSON = JSON.new()
		var parse_result:Error = json.parse(json_string)
		if (parse_result != OK):
			continue
		var data = json.get_data()
		current_language = data["current_language"]
		force_integer_scaling = data["force_integer_scaling"]
		subweapon_with_up = data["subweapon_with_up"]
		is_fullscreen = data["is_fullscreen"]
		music_volume_percentage = data["music_volume_percentage"]
		sfx_volume_percentage = data["sfx_volume_percentage"]
		window_scale = data["window_scale"]
		keyboard_mappings["up"] = data["up_key"]
		keyboard_mappings["down"] = data["down_key"]
		keyboard_mappings["left"] = data["left_key"]
		keyboard_mappings["right"] = data["right_key"]
		keyboard_mappings["jump"] = data["jump_key"]
		keyboard_mappings["attack"] = data["attack_key"]
		keyboard_mappings["crouch"] = data["crouch_key"]
		keyboard_mappings["subweapon"] = data["subweapon_key"]
		keyboard_mappings["start"] = data["start_key"]
		keyboard_mappings["debug"] = data["debug_key"]
		keyboard_mappings["accept"] = data["accept_key"]
		keyboard_mappings["cancel"] = data["cancel_key"]
		keyboard_mappings["fullscreen"] = data["fullscreen_key"]
		keyboard_mappings["ui_up"] = data["ui_up_key"]
		keyboard_mappings["ui_down"] = data["ui_down_key"]
		keyboard_mappings["ui_left"] = data["ui_left_key"]
		keyboard_mappings["ui_right"] = data["ui_right_key"]
		keyboard_mappings["ui_accept"] = data["ui_accept_key"]
		keyboard_mappings["ui_cancel"] = data["ui_cancel_key"]
		keyboard_mappings["a"] = data["a_key"]
		keyboard_mappings["b"] = data["b_key"]
		update_input_map()
		copy_mappings(keyboard_mappings, new_keyboard_mappings)
	initialized = true

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	load_settings()

func _notification(what:int) -> void:
	if(what == NOTIFICATION_WM_CLOSE_REQUEST):
		if(has_unsaved_changes):
			save_settings()
		get_tree().quit()
