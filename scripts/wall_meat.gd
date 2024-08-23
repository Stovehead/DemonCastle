extends Node2D

@onready var persistent_component:PersistentObject = $PersistentObject

var random_number:int


func _on_persistent_object_new_instance(persistent:PersistentObject) -> void:
	random_number = randi()
	print("New: ", random_number)
	persistent.variables.random_number = random_number

func _on_persistent_object_retreived_data(variables: Dictionary) -> void:
	random_number = variables.random_number
	print("Retrieve: ", random_number)
