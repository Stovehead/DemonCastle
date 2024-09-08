class_name RemappingMenu
extends Menu

const OVERLAPPING_COLOR:Color = Color("bcbe00")

@export var control_selections:Array[ControlSelection]
@export var apply_selection:Selection
@export var reset_selection:Selection
@export var apply_reset_container:Container
@export var yes_no_menu:Menu
@export var yes_selection:Selection
@export var no_selection:Selection

var has_overlapping_inputs:bool = false

func revert() -> void:
	Settings.copy_mappings(Settings.keyboard_mappings, Settings.new_keyboard_mappings)
	for selection in control_selections:
			selection.update_control_label()

func apply() -> void:
	SfxManager.play_sound_effect_no_overlap(SfxManager.HEART)
	Settings.copy_mappings(Settings.new_keyboard_mappings, Settings.keyboard_mappings)
	Settings.update_input_map()
	Settings.has_unsaved_changes = true

func reset() -> void:
	SfxManager.play_sound_effect_no_overlap(SfxManager.HEART)
	Settings.copy_mappings(Settings.default_keyboard_mappings, Settings.keyboard_mappings)
	Settings.update_input_map()
	revert()
	Settings.has_unsaved_changes = true

func update_active_and_focus(new_active:bool, new_focused:bool) -> void:
	super.update_active_and_focus(new_active, new_focused)
	if(!new_active && !new_focused):
		revert()

func return_from_yes_no_menu() -> void:
	yes_no_menu.just_mapped_key = false
	cursor.visible = true
	yes_no_menu.visible = false
	yes_no_menu.focused = false
	yes_no_menu.active = false
	active = true
	apply_reset_container.visible = true

func _ready() -> void:
	super._ready()
	apply_selection.selected.connect(_on_apply_or_reset)
	reset_selection.selected.connect(_on_apply_or_reset)
	yes_selection.selected.connect(_on_yes)
	no_selection.selected.connect(_on_no)

func _on_yes() -> void:
	return_from_yes_no_menu()
	if(current_selection == apply_selection):
		apply()
	elif(current_selection == reset_selection):
		reset()

func _on_no() -> void:
	return_from_yes_no_menu()

func _on_apply_or_reset() -> void:
	yes_no_menu.just_mapped_key = true
	cursor.visible = false
	yes_no_menu.focused = true
	yes_no_menu.active = true
	yes_no_menu.visible = true
	yes_no_menu.update_cursor.call_deferred()
	active = false
	apply_reset_container.visible = false
