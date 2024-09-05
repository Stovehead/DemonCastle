class_name SubMenu
extends Selection

@export var menu:Menu
@export var label:Label

func set_active(new_active:bool) -> void:
	menu.active = new_active

func set_focused(new_focused:bool) -> void:
	menu.focused = new_focused

func _on_accepted() -> void:
	active = false
	menu.active = true
	parent_menu.focused = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if(Input.is_action_just_pressed("deny")):
		menu.active = false
		active = true
		parent_menu.active = true
