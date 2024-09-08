class_name OptionsScreen
extends Control

signal selected_exit

func _on_selected_exit():
	selected_exit.emit()
