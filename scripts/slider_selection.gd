class_name SliderSelection
extends Selection

@export var property:String
@export var value_range:Vector2
@export var increment:float
@export var slider_label:Label
@export var format_string:String

var current_value:float

func set_value_to_current() -> void:
	var new_value:float = Settings.get(property)
	slider_label.text = format_string % new_value
	current_value = new_value

func _ready() -> void:
	set_value_to_current()

func _input(event: InputEvent) -> void:
	if(!focused || !parent_menu.active):
		return
	if(event.is_action_pressed("left", true) || event.is_action_pressed("ui_left", true)):
		current_value -= increment
	elif(event.is_action_pressed("right", true) || event.is_action_pressed("ui_right", true)):
		current_value += increment
	else:
		return
	if(current_value > value_range.y):
		current_value = value_range.y
	elif(current_value < value_range.x):
		current_value = value_range.x
	else:
		SfxManager.play_sound_effect_no_overlap(SfxManager.HEART)
		slider_label.text = format_string % current_value
		Settings.set(property, current_value)
