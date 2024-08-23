class_name PersistentObject
extends Node

signal retreived_data(variables:Dictionary)
signal new_instance(persistent_component:PersistentObject)

@export var unique_name:String
var variables:Dictionary

func _ready() -> void:
	if(unique_name != ""):
		if(Globals.persistent_objects.has(unique_name)):
			variables = Globals.persistent_objects[unique_name]
			retreived_data.emit(variables)
		else:
			new_instance.emit(self)

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		Globals.persistent_objects[unique_name] = variables
