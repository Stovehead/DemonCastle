class_name Selection
extends Control

signal gained_focus
signal lost_focus

var active:bool = false:
	set(new_active):
		set_active(new_active)
		active = new_active
var focused:bool = false:
	set(new_focused):
		set_focused(new_focused)
		focused = new_focused

@export var parent_menu:Menu

func set_active(_new_active:bool) -> void:
	pass

func set_focused(_new_focused:bool) -> void:
	pass

func _on_accepted() -> void:
	pass
