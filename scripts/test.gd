extends Node2D

@onready var player:Node2D = $Player
@onready var camera:Camera2D = $Camera

func _process(delta) -> void:
	camera.global_position = floor(player.global_position)
