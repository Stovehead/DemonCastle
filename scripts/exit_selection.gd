class_name ExitSelection
extends Selection

signal selected_exit

func _on_accepted() -> void:
	super._on_accepted()
	selected_exit.emit()
