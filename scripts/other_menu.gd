class_name OtherMenu
extends Menu

@export var reset_all_selection:Selection
@export var yes_no_menu:Menu

func _on_reset_all() -> void:
	yes_no_menu.ignore_input = true
	cursor.visible = false
	yes_no_menu.focused = true
	yes_no_menu.active = true
	yes_no_menu.visible = true
	yes_no_menu.update_cursor.call_deferred()
	active = false
	reset_all_selection.visible = false

func return_from_yes_no_menu() -> void:
	yes_no_menu.ignore_input = false
	cursor.visible = true
	yes_no_menu.visible = false
	yes_no_menu.focused = false
	yes_no_menu.active = false
	active = true
	reset_all_selection.visible = true

func _on_yes() -> void:
	return_from_yes_no_menu()
	Settings.reset_settings()
	SfxManager.play_sound_effect_no_overlap(SfxManager.HEART)

func _on_no() -> void:
	return_from_yes_no_menu()
