extends Upgrade

@export var num_points:int = 100
@export var sprite:Sprite2D
@onready var points_graphic:PackedScene = preload("res://scenes/points.tscn")

func _ready() -> void:
	match(num_points):
		100:
			sprite.frame = 0
		200:
			sprite.frame = 0
		400:
			sprite.frame = 1
		700:
			sprite.frame = 2

func do_upgrade(player:Player):
	Globals.game_instance.score += num_points
	Globals.game_instance.score_changed.emit(Globals.game_instance.score)
	SfxManager.play_sound_effect(SfxManager.MONEY_BAG)
	var new_points_graphic:Sprite2D = points_graphic.instantiate()
	match(num_points):
		100:
			new_points_graphic.frame = 0
		200:
			new_points_graphic.frame = 1
		400:
			new_points_graphic.frame = 2
		700:
			new_points_graphic.frame = 3
	player.add_sibling(new_points_graphic)
	new_points_graphic.global_position = player.global_position
	get_parent().queue_free()
