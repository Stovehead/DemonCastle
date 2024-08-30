extends Upgrade

const NUM_POINTS:int = 700
const POINTS_FRAME:int = 3

@onready var doubler_sprite:Texture = preload("res://media/graphics/doubler.png")
@onready var tripler_sprite:Texture = preload("res://media/graphics/tripler.png")
@onready var points_graphic:PackedScene = preload("res://scenes/points.tscn")

@export var sprite:Sprite2D

var level:int = 0

func _ready() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	if(Globals.current_player.max_num_subweapons == 1):
		sprite.texture = doubler_sprite
		level = 2
	elif(Globals.current_player.max_num_subweapons == 2):
		sprite.texture = tripler_sprite
		level = 3
	else:
		get_parent().queue_free()

func do_upgrade(player:Player):
	if(player.current_subweapon == Player.Subweapons.NONE || player.current_subweapon == Player.Subweapons.STOPWATCH || player.max_num_subweapons == level):
		Globals.game_instance.score += NUM_POINTS
		Globals.game_instance.score_changed.emit(Globals.game_instance.score)
		SfxManager.play_sound_effect(SfxManager.MONEY_BAG)
		var new_points_graphic:Sprite2D = points_graphic.instantiate()
		new_points_graphic.frame = POINTS_FRAME
		player.add_sibling(new_points_graphic)
		new_points_graphic.global_position = player.global_position
		get_parent().queue_free()
		return
	player.max_num_subweapons = level
	player.max_subweapons_changed.emit(level)
	SfxManager.play_sound_effect(SfxManager.WHIP_UPGRADE)
	get_parent().queue_free()
