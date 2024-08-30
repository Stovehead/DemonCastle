extends Node2D

@onready var block1:BreakableBlock = $Block1
@onready var block2:BreakableBlock = $Block2

func _ready() -> void:
	if(!block1.monitoring && !block2.broken):
		block2.monitoring = true

func _on_block_1_whip_exited() -> void:
	block2.monitoring = true
