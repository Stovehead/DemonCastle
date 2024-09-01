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
@export var copyright_text:Label
@export var menu:Control
@export var heart_container:MarginContainer
@onready var flash_timer:Timer = $FlashTimer
@onready var start_timer:Timer = $StartTimer
@onready var fades:CanvasLayer = $Fades
@onready var fade_1:ColorRect = $Fades/ColorRect
@onready var fade_2:ColorRect = $Fades/ColorRect2
@onready var fade_3:ColorRect = $Fades/ColorRect3
@onready 
var started:bool = false
var current_option:int = 0

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
				1:
					select_options.emit()
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
	start_option.modulate.a = 1 - start_option.modulate.a

func _on_start_timer_timeout() -> void:
	select_start.emit()

func reset():
	started = false
	current_option = 0
	heart_container.add_theme_constant_override("margin_top", 0)
	flash_timer.stop()
	start_text.visible = true
	menu.visible = false
	copyright_text.modulate.a = 1
