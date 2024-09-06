class_name OptionsScreen
extends Control

signal selected_exit

@export var must_restart_text:Label

func _on_selected_exit():
	selected_exit.emit()

func _process(delta: float) -> void:
	if(is_instance_valid(must_restart_text)):
		must_restart_text.visible = Settings.must_restart
