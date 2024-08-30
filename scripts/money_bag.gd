extends Upgrade

const POINTS_NEW_PALETTES:Array[Vector4] = [
	Vector4(0.9, 0.8, 0.6, 1.0),
	Vector4(0.0, 0.3, 0.8, 1.0),
	Vector4(0.0, 0.0, 0.0, 1.0),
	Vector4(0.7, 0.1, 0.1, 1.0),
	Vector4(0.9, 0.4, 0.8, 1.0),
	Vector4(0.0, 0.0, 0.0, 0.1),
	Vector4(0.9, 0.8, 0.6, 1.0),
	Vector4(0.0, 0.3, 0.8, 1.0),
	Vector4(0.0, 0.0, 0.0, 1.0),
	Vector4(0.7, 0.1, 0.1, 1.0),
	Vector4(0.9, 0.4, 0.8, 1.0),
	Vector4(0.0, 0.0, 0.0, 1.0),
]

const POINTS_NUM_NEW_PALETTES:int = 4

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
		1000:
			sprite.frame = 0

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
		1000:
			new_points_graphic.frame = 4
			if(new_points_graphic.material is ShaderMaterial):
				new_points_graphic.material.set_shader_parameter("num_new_palettes", POINTS_NUM_NEW_PALETTES)
				new_points_graphic.material.set_shader_parameter("new_palettes", POINTS_NEW_PALETTES)
	player.add_sibling(new_points_graphic)
	new_points_graphic.global_position = player.global_position
	get_parent().queue_free()
