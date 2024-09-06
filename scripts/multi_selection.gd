class_name MultiSelection
extends Selection

@export var property:String
@export var selections:Array[String]
@export var values:Array[Variant]
@export var selection_label:Label
@export var default_selection:int = 0
@export var changed_signal:String

var current_selection:int = 0

func set_selection_to_current() -> void:
	var index:int = values.find(Settings.get(property))
	if(index == -1):
		return
	selection_label.text = selections[index]
	current_selection = index

func _ready() -> void:
	if(changed_signal != ""):
		Settings.connect(changed_signal, _on_property_changed)
	set_selection_to_current()

func _on_property_changed() -> void:
	if(Settings.get(property) == values[current_selection]):
		return
	set_selection_to_current()

func _input(event: InputEvent) -> void:
	if(!focused || !parent_menu.active):
		return
	if(event.is_action_pressed("left", false)):
		current_selection -= 1
	elif(event.is_action_pressed("right", false)):
		current_selection += 1
	else:
		return
	SfxManager.play_sound_effect_no_overlap(SfxManager.SELECT)
	if(current_selection >= selections.size()):
		current_selection = 0
	elif(current_selection < 0):
		current_selection = selections.size() - 1
	selection_label.text = selections[current_selection]
	Settings.set(property, values[current_selection])
