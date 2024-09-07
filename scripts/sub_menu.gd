class_name SubMenu
extends Selection

@export var menu:Menu

var just_entered:bool = false

func _ready() -> void:
	focused = focused

func update_active_and_focus(new_active:bool, new_focused:bool):
	menu.visible = new_focused
	menu.active = new_active

func _on_accepted() -> void:
	active = true
	menu.set_deferred("focused", true)
	parent_menu.focused = false

func _process(_delta: float) -> void:
	if(Input.is_action_just_pressed("cancel") && menu.active && menu.focused && !menu.just_mapped_key):
		active = false
		menu.focused = false
		parent_menu.focused = true
