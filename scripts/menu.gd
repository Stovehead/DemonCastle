class_name Menu
extends Control

const UNFOCUSED_COLOR:Color = Color(0.5, 0.5, 0.5)

@export var default_selection:Selection
@export var labels:Array[Label]
@export var cursor:TextureRect
@export var hide_cursor_on_lost_focus:bool = false
@export var grey_out_current_selection_on_lost_focus:bool = false

var current_selection:Selection
var ignore_input:bool = false

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
			if(is_instance_valid(current_selection) && label == current_selection.label && !grey_out_current_selection_on_lost_focus && active):
				continue
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

func update_cursor() -> void:
	cursor.global_position = current_selection.global_position + current_selection.cursor_offset
	update_active_and_focus(active, focused)

func update_selection(new_selection:Selection) -> void:
	if(new_selection == null):
		return
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
	if(ignore_input):
		ignore_input = false
	elif(Input.is_action_just_pressed("up") || Input.is_action_just_pressed("ui_up") && is_instance_valid(current_selection.up_selection)):
		update_selection(current_selection.up_selection)
	elif(Input.is_action_just_pressed("down") || Input.is_action_just_pressed("ui_down") && is_instance_valid(current_selection.down_selection)):
		update_selection(current_selection.down_selection)
	elif(Input.is_action_just_pressed("left") || Input.is_action_just_pressed("ui_left") && is_instance_valid(current_selection.left_selection)):
		update_selection(current_selection.left_selection)
	elif(Input.is_action_just_pressed("right") || Input.is_action_just_pressed("ui_right") && is_instance_valid(current_selection.right_selection)):
		update_selection(current_selection.right_selection)
	elif(Input.is_action_just_pressed("accept") || Input.is_action_just_pressed("ui_accept") || Input.is_action_just_pressed("start")):
		current_selection._on_accepted()
