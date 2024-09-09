class_name TranslatableMultiSelection
extends MultiSelection

@export var translatable_selections:Dictionary

func update_text() -> void:
	if(translatable_selections.has(Settings.current_language)):
		selections = translatable_selections[Settings.current_language]
	set_selection_to_current()

func _ready() -> void:
	super._ready()
	update_text()
	Settings.language_changed.connect(_language_changed)

func _language_changed() -> void:
	update_text()
