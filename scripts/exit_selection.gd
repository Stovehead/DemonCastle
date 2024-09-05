class_name ExitSelection
extends Selection

signal selected_exit

func _on_accepted() -> void:
	selected_exit.emit()
