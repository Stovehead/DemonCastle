class_name Flame
extends Node2D

enum Items{
	NOTHING,
	SMALL_HEART,
	BIG_HEART,
	WHIP_UPGRADE,
	MONEY_BAG_100,
	MONEY_BAG_400,
	MONEY_BAG_700,
}
@onready var droppable_items = [
	null,
	preload("res://scenes/small_heart.tscn"),
	preload("res://scenes/big_heart.tscn"),
	preload("res://scenes/whip_upgrade.tscn"),
	preload("res://scenes/money_bag_100.tscn"),
	preload("res://scenes/money_bag_400.tscn"),
	preload("res://scenes/money_bag_700.tscn")
]
var item_to_drop:int = 0

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(item_to_drop != 0):
		var item_instance = droppable_items[item_to_drop].instantiate()
		if(item_instance is Node2D):
			item_instance.position = position
		add_sibling(item_instance)
	queue_free()
