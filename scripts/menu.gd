class_name Menu
extends Control

const UNFOCUSED_COLOR:Color = Color(0.5, 0.5, 0.5)

@export var default_selection:Selection
@export var labels:Array[Label]
@export var cursor:TextureRect
@export var hide_cursor_on_lost_focus:bool = false

var current_selection:Selection

@export var active:bool:
	set(new_active):
		update_active_and_focus(new_active, focused)
		active = new_active
@export var focused:bool:
	set(new_focused):
		update_active_and_focus(active, new_focused)
		focused = new_focused

func update_active_and_focus(new_active:bool, new_focused:bool):
	if(new_focused):
		for label in labels:
			label.self_modulate = Color.WHITE
	else:
		for label in labels:
			label.self_modulate = UNFOCUSED_COLOR
	if(is_instance_valid(cursor)):
		if(new_active && new_focused):
			cursor.modulate.a = 1
			cursor.self_modulate = Color.WHITE
		elif(!new_focused):
			if(hide_cursor_on_lost_focus):
				cursor.modulate.a = 0
			else:
				cursor.self_modulate = UNFOCUSED_COLOR
		else:
			cursor.modulate.a = 0

func update_cursor() -> void:
	cursor.global_position = current_selection.global_position + current_selection.cursor_offset
	update_active_and_focus(active, focused)

func update_selection(new_selection:Selection) -> void:
	SfxManager.play_sound_effect(SfxManager.SELECT)
	current_selection.focused = false
	current_selection = new_selection
	current_selection.focused = true
	update_cursor()

func _ready() -> void:
	current_selection = default_selection
	current_selection.focused = true
	update_cursor()

func _process(_delta: float) -> void:
	if(!active || !focused):
		return
	if(Input.is_action_just_pressed("up") && is_instance_valid(current_selection.up_selection)):
		update_selection(current_selection.up_selection)
	elif(Input.is_action_just_pressed("down") && is_instance_valid(current_selection.down_selection)):
		update_selection(current_selection.down_selection)
	elif(Input.is_action_just_pressed("left") && is_instance_valid(current_selection.left_selection)):
		update_selection(current_selection.left_selection)
	elif(Input.is_action_just_pressed("right") && is_instance_valid(current_selection.right_selection)):
		update_selection(current_selection.right_selection)
	if(Input.is_action_just_pressed("accept")):
		current_selection._on_accepted()
