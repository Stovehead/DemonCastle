extends Node

const RESOLUTION:Vector2i = Vector2i(384, 216)

signal language_changed
signal fullscreen_changed

var has_unsaved_changes:bool = false
var must_restart:bool = false
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
				must_restart = true
		if(new_force_integer_scaling):
			ProjectSettings.set("display/window/stretch/scale_mode", "integer")
		else:
			ProjectSettings.set("display/window/stretch/scale_mode", "fractional")

func set_language_from_system() -> void:
	if(OS.get_locale() == "ja"):
		current_language = "jp"

func save_settings() -> void:
	var save_dict:Dictionary = {
		"current_language": current_language,
		"music_volume_percentage": music_volume_percentage,
		"sfx_volume_percentage": sfx_volume_percentage,
		"window_scale": window_scale,
		"is_fullscreen": is_fullscreen,
		"force_integer_scaling": force_integer_scaling,
	}
	var save_file:FileAccess = FileAccess.open("user://settings.save", FileAccess.WRITE)
	var json_string:String = JSON.stringify(save_dict)
	save_file.store_line(json_string)
	if(must_restart):
		ProjectSettings.save()
	has_unsaved_changes = false
	must_restart = false

func load_settings() -> void:
	if(!FileAccess.file_exists("user://settings.save")):
		set_language_from_system()
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
		is_fullscreen = data["is_fullscreen"]
		music_volume_percentage = data["music_volume_percentage"]
		sfx_volume_percentage = data["sfx_volume_percentage"]
		window_scale = data["window_scale"]
	initialized = true

func _ready() -> void:
	get_tree().set_auto_accept_quit(false)
	load_settings()

func _notification(what:int) -> void:
	if(what == NOTIFICATION_WM_CLOSE_REQUEST):
		if(has_unsaved_changes):
			save_settings()
		get_tree().quit()
