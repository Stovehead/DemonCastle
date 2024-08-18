class_name TitleScreen
extends Control

const NUM_OPTIONS:int = 3
const SPACE_BETWEEN_OPTIONS:int = 16

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
var started:bool = false
var current_option:int = 0

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("start")):
		if(!started):
			start_text.visible = false
			copyright_text.modulate.a = 0
			menu.visible = true
			started = true
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
