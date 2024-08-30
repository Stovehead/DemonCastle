class_name Flame
extends Node2D

const RANDOM_ITEM_CHANCE:int = 16
const WHIP_UPGRADE_1_THRESHOLD:int = 4
const WHIP_UPGRADE_2_THRESHOLD:int = 8

enum Items{
	NOTHING,
	SMALL_HEART,
	BIG_HEART,
	SMALL_HEART_OR_MONEY_BAG,
	MONEY_BAG_100,
	MONEY_BAG_400,
	MONEY_BAG_700,
	KNIFE,
	AXE,
	CROSS,
	HOLY_WATER,
	STOPWATCH,
	ROSARY,
	JAR,
	WHIP_UPGRADE,
}

@onready var droppable_items = [
	null,
	preload("res://scenes/small_heart.tscn"),
	preload("res://scenes/big_heart.tscn"),
	preload("res://scenes/small_heart.tscn"),
	preload("res://scenes/money_bag_100.tscn"),
	preload("res://scenes/money_bag_400.tscn"),
	preload("res://scenes/money_bag_700.tscn"),
	preload("res://scenes/knife_item.tscn"),
	preload("res://scenes/axe_item.tscn"),
	preload("res://scenes/cross_item.tscn"),
	preload("res://scenes/holy_water_item.tscn"),
	preload("res://scenes/stopwatch_item.tscn"),
	preload("res://scenes/rosary.tscn"),
	preload("res://scenes/jar.tscn"),
	preload("res://scenes/whip_upgrade.tscn")
]

var item_to_drop:int = 0

func get_random_item() -> int:
	if(randi() % 2 == 0):
		return Items.SMALL_HEART
	return Items.MONEY_BAG_100

func is_item_players_subweapon(item:int) -> bool:
	if(!is_instance_valid(Globals.current_player)):
		return false
	var player_subweapon = Globals.current_player.current_subweapon
	return (item >= Items.KNIFE && item <= Items.STOPWATCH && item - Items.KNIFE + 1 == player_subweapon)

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if(item_to_drop == Items.NOTHING):
		var random_number:int = randi() % RANDOM_ITEM_CHANCE
		if(random_number == 0):
			item_to_drop = Items.SMALL_HEART
		elif(random_number == 1):
			item_to_drop = Globals.game_instance.current_stage.big_item_list.pick_random()
		else:
			queue_free()
			return
	elif(item_to_drop == Items.SMALL_HEART_OR_MONEY_BAG || is_item_players_subweapon(item_to_drop)):
		item_to_drop = get_random_item()
	if(item_to_drop == Items.SMALL_HEART || item_to_drop == Items.MONEY_BAG_100):
		if(Globals.current_player.whip_level + Globals.game_instance.num_whip_upgrades == 1 && Globals.current_player.num_hearts >= WHIP_UPGRADE_1_THRESHOLD):
			item_to_drop = Items.WHIP_UPGRADE
		elif(Globals.current_player.whip_level + Globals.game_instance.num_whip_upgrades == 2 && Globals.current_player.num_hearts >= WHIP_UPGRADE_2_THRESHOLD):
			item_to_drop = Items.WHIP_UPGRADE
	var item_instance:Node2D = droppable_items[item_to_drop].instantiate()
	item_instance.position = position
	add_sibling(item_instance)
	queue_free()
