class_name TranslatableLabel
extends Label

@export var strings:Dictionary

func update_text() -> void:
	if(strings.has(Settings.current_language)):
		text = strings[Settings.current_language]

func _ready() -> void:
	update_text()
	Settings.language_changed.connect(_language_changed)

func _language_changed() -> void:
	update_text()
