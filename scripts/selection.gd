class_name Selection
extends MarginContainer

@export var left_selection:Selection
@export var right_selection:Selection
@export var up_selection:Selection
@export var down_selection:Selection

@export var parent_menu:Menu

@export var cursor_offset:Vector2 = Vector2(-16, 0)

var active:bool = false:
	set(new_active):
		update_active_and_focus(new_active, focused)
		active = new_active
var focused:bool = false:
	set(new_focused):
		update_active_and_focus(active, new_focused)
		focused = new_focused

func update_active_and_focus(_new_active:bool, _new_focused:bool):
	pass

func _on_accepted() -> void:
	pass
