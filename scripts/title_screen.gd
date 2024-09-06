class_name TitleScreen
extends Control

const NUM_OPTIONS:int = 3
const SPACE_BETWEEN_OPTIONS:int = 16
const FADE_LENGTH:float = 0.166

signal select_start
signal select_options
signal select_quit

@export var start_text:Label
@export var start_option:Label
@export var options_option:Label
@export var copyright_text:Label
@export var menu:Control
@export var heart_container:MarginContainer
@onready var flash_timer:Timer = $FlashTimer
@onready var start_timer:Timer = $StartTimer
@onready var options_timer:Timer = $OptionsTimer
@onready var fades:CanvasLayer = $Fades
@onready var fade_1:ColorRect = $Fades/ColorRect
@onready var fade_2:ColorRect = $Fades/ColorRect2
@onready var fade_3:ColorRect = $Fades/ColorRect3
@onready var options_music:AudioStream = preload("res://media/music/options.ogg")
@export var dotted_line_1:TextureRect
@export var dotted_line_2:TextureRect
@export var bottom_line:ColorRect
@export var logo_en:TextureRect
@export var logo_jp:TextureRect
@export var bat_animation_player:AnimationPlayer
var started:bool = false
var current_option:int = 0

func reset() -> void:
	started = false
	current_option = 0
	heart_container.add_theme_constant_override("margin_top", 0)
	flash_timer.stop()
	start_text.visible = true
	menu.visible = false
	copyright_text.modulate.a = 1
	Globals.entered_konami_code = false
	bat_animation_player.play("default")
	bat_animation_player.queue("fly")

func exit_options() -> void:
	flash_timer.stop()
	bat_animation_player.stop()
	bat_animation_player.play("default")
	bat_animation_player.queue("fly")

func update_language() -> void:
	match(Settings.current_language):
		"en":
			dotted_line_1.visible = true
			dotted_line_2.visible = true
			logo_en.visible = true
			bottom_line.visible = true
			logo_jp.visible = false
			fade_1.position.y = 134
			fade_2.position.y = 160
			fade_3.position.y = 120
		"jp":
			dotted_line_1.visible = false
			dotted_line_2.visible = false
			logo_en.visible = false
			bottom_line.visible = false
			logo_jp.visible = true
			fade_1.position.y = 161
			fade_2.position.y = 187
			fade_3.position.y = 147

func _ready() -> void:
	update_language()
	Settings.language_changed.connect(_language_changed)
	bat_animation_player.play("default")
	bat_animation_player.queue("fly")

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("start") && !fades.visible && start_timer.is_stopped()):
		if(!started):
			fades.visible = true
			fade_1.visible = true
			fade_1.material.set_shader_parameter("start_time", ShaderTime.time)
			fade_1.material.set_shader_parameter("fade_length", FADE_LENGTH)
			fade_1.material.set_shader_parameter("backwards", false)
			fade_2.visible = true
			fade_2.material.set_shader_parameter("start_time", ShaderTime.time)
			fade_2.material.set_shader_parameter("fade_length", FADE_LENGTH)
			fade_2.material.set_shader_parameter("backwards", false)
			await get_tree().create_timer(FADE_LENGTH, true, true).timeout
			start_text.visible = false
			copyright_text.modulate.a = 0
			fade_1.visible = false
			fade_2.visible = false
			fade_3.visible = true
			fade_3.material.set_shader_parameter("start_time", ShaderTime.time)
			fade_3.material.set_shader_parameter("fade_length", FADE_LENGTH)
			fade_3.material.set_shader_parameter("backwards", true)
			menu.visible = true
			await get_tree().create_timer(FADE_LENGTH, true, true).timeout
			started = true
			fades.visible = false
		else:
			match(current_option):
				0:
					flash_timer.start()
					start_timer.start()
					bat_animation_player.pause()
				1:
					flash_timer.start()
					options_timer.start()
					if(is_instance_valid(Globals.game_instance)):
						Globals.game_instance.music_player.stream = options_music
						Globals.game_instance.music_player.play()
					bat_animation_player.pause()
				2:
					select_quit.emit()

	if(started):
		var input_direction:int = 0
		if(Input.is_action_just_pressed("up")):
			input_direction -= 1
		if(Input.is_action_just_pressed("down")):
			input_direction += 1
		if(input_direction != 0 && flash_timer.is_stopped()):
			current_option += input_direction
			if(current_option < 0):
				current_option = NUM_OPTIONS - 1
			current_option %= NUM_OPTIONS
			heart_container.add_theme_constant_override("margin_top", current_option * SPACE_BETWEEN_OPTIONS)
			SfxManager.play_sound_effect_no_overlap(SfxManager.SELECT)

func _on_flash_timer_timeout() -> void:
	match(current_option):
		0:
			start_option.modulate.a = 1 - start_option.modulate.a
		1:
			options_option.modulate.a = 1 - options_option.modulate.a

func _on_start_timer_timeout() -> void:
	select_start.emit()

func _on_options_timer_timeout() -> void:
	select_options.emit()

func _language_changed() -> void:
	update_language()
