class_name Menu
extends Control

@export var selections:Array[Selection]
@export var cursor_container:MarginContainer
@export var cursor:TextureRect
@export var space_between_selections:int = 16
@export var active:bool = false:
	set(new_active):
		if(!new_active):
			if(is_instance_valid(cursor)):
				cursor.modulate.a = 0
		else:
			if(is_instance_valid(cursor)):
				cursor.modulate.a = 1
		active = new_active

@export var focused:bool = false:
	set(new_focused):
		if(!new_focused):
			if(is_instance_valid(cursor)):
				cursor.self_modulate = MultiSelection.UNFOCUSED_COLOR
		else:
			if(is_instance_valid(cursor)):
				cursor.self_modulate = Color.WHITE
			if(!active):
				for selection in selections:
					selection.focused = false
		focused = new_focused

var current_selection:int = 0
var num_selections:int

func update_visibility(is_active:bool, is_focused:bool) -> void:
	if(!is_focused):
		for selection in selections:
			selection.focused = false
	if(is_active && is_focused):
		if(is_instance_valid(cursor)):
			cursor.self_modulate = Color.WHITE
		for selection in selections:
			selection.focused = true

func _ready() -> void:
	num_selections = max(selections.size(), 1)

func _process(_delta: float) -> void:
	var input_direction:int = 0
	if(Input.is_action_just_pressed("up")):
		input_direction -= 1
	if(Input.is_action_just_pressed("down")):
		input_direction += 1
	if(input_direction != 0 && active && focused):
		selections[current_selection].focused = false
		current_selection += input_direction
		if(current_selection < 0):
			current_selection = num_selections - 1
		current_selection %= num_selections
		selections[current_selection].focused = true
		cursor_container.add_theme_constant_override("margin_top", current_selection * space_between_selections)
		SfxManager.play_sound_effect_no_overlap(SfxManager.SELECT)
	if(Input.is_action_just_pressed("accept") && active):
		selections[current_selection]._on_accepted()

func _on_submenu_exited() -> void:
	active = true
	focused = true
