class_name Stairs
extends Node2D

const SINGLE_STAIR_HEIGHT:int = 8

@onready var top:Area2D = $Top

@export var height:int = 2

@export_range(-1, 1, 2) var direction:int = 1

func update_stairs() -> void:
	top.position = Vector2(SINGLE_STAIR_HEIGHT * height * direction, SINGLE_STAIR_HEIGHT * height * -1)

func _ready() -> void:
	update_stairs()
	pass
