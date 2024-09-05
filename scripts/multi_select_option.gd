class_name MultiSelection
extends Selection

const UNFOCUSED_COLOR:Color = Color(0.5, 0.5, 0.5, 1)

@export var left_label:Label
@export var right_label:Label

func set_active(new_active:bool) -> void:
	if(new_active):
		left_label.self_modulate = Color.WHITE
		right_label.self_modulate = Color.WHITE
	else:
		left_label.self_modulate = UNFOCUSED_COLOR
		right_label.self_modulate = UNFOCUSED_COLOR

func set_focused(new_focused:bool) -> void:
	left_label.visible = new_focused || active
	right_label.visible = new_focused || active

func _on_accepted() -> void:
	pass
