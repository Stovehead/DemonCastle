class_name ControlSelection
extends Selection

const WAIT_TIME:int = 5
const FORMAT_STRING:String = "%d..."

enum Type{
	KEYBOARD,
	CONTROLLER
}

var time_left:int = 0
var timer:Timer

@export var action:String
@export var input_type:Type
@export var control_label:Label

func update_control_label() -> void:
	if(active):
		control_label.text = FORMAT_STRING % time_left
	else:
		var label_text = OS.get_keycode_string(Settings.new_keyboard_mappings[action]).to_upper()
		for i in range(label_text.length()):
			if(!Settings.font.has_char(label_text.unicode_at(i))):
				label_text[i] = '?'
		control_label.text = label_text

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = false
	timer.one_shot = false
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)
	update_control_label()

func _on_accepted() -> void:
	if(active):
		return
	parent_menu.active = false
	active = true
	time_left = WAIT_TIME
	update_control_label()
	timer.start()

func _on_timer_timeout() -> void:
	if(time_left <= 0):
		active = false
		parent_menu.active = true
		update_control_label()
		timer.stop()
	else:
		time_left -= 1
		update_control_label()

func _unhandled_input(event: InputEvent) -> void:
	if(!active):
		return
	if(event is InputEventKey):
		if(event.pressed && input_type == Type.KEYBOARD):
			Settings.new_keyboard_mappings[action] = event.keycode
			active = false
			parent_menu.just_mapped_key = true
			parent_menu.active = true
			timer.stop()
			update_control_label()
