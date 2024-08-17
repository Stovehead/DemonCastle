extends Node2D

@onready var flame:PackedScene = preload("res://scenes/flame.tscn")
@export var item_to_drop: Flame.Items

func _on_got_hit(attacker: Hurtbox) -> void:
	var new_flame:Flame = flame.instantiate()
	new_flame.position = position
	if(item_to_drop == Flame.Items.WHIP_UPGRADE && Globals.current_player.whip_level + Globals.game_instance.num_whip_upgrades >= 3):
		item_to_drop = Flame.Items.SMALL_HEART
	new_flame.item_to_drop = item_to_drop
	add_sibling(new_flame)
	queue_free()
