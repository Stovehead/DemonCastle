class_name FlameSpawner
extends Node2D

@onready var flame:PackedScene = preload("res://scenes/flame.tscn")
@export var item_to_drop: Flame.Items

func get_random_item() -> int:
	if(randi() % 2 == 0):
		return Flame.Items.SMALL_HEART
	return Flame.Items.MONEY_BAG_100

func is_item_players_subweapon(item:int) -> bool:
	if(!is_instance_valid(Globals.current_player)):
		return false
	var player_subweapon = Globals.current_player.current_subweapon
	return (item >= Flame.Items.KNIFE && item <= Flame.Items.STOPWATCH && item - Flame.Items.KNIFE + 1 == player_subweapon)

func spawn_flame() -> void:
	var new_flame:Flame = flame.instantiate()
	if(item_to_drop == Flame.Items.WHIP_UPGRADE && Globals.current_player.whip_level + Globals.game_instance.num_whip_upgrades >= 2):
		item_to_drop = get_random_item()
	elif(item_to_drop == Flame.Items.WHIP_UPGRADE_2 && Globals.current_player.whip_level + Globals.game_instance.num_whip_upgrades >= 3):
		item_to_drop = get_random_item()
	elif(is_item_players_subweapon(item_to_drop)):
		item_to_drop = get_random_item()
	new_flame.item_to_drop = item_to_drop
	Globals.game_instance.current_stage.objects.add_child(new_flame)
	new_flame.global_position = global_position
