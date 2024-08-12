class_name Whip
extends Area2D

@export var new_position:Vector2:
	set(new_new_position):
		new_position = new_new_position
		position.x = new_position.x * scale.x
		position.y = new_position.y
