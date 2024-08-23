extends Node2D

var used:bool = false

@onready var persistent_component:PersistentObject = $PersistentObject
@onready var block1:BreakableBlock = $Block1
@onready var block2:BreakableBlock = $Block2

func _ready() -> void:
	if(used):
		block1.monitoring = false

func _on_persistent_object_retreived_data(variables: Dictionary) -> void:
	if(variables.has("used")):
		used = variables.used

func _on_block_1_whip_exited() -> void:
	persistent_component.variables.used = true
	block2.monitoring = true
