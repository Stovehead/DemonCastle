class_name Subweapon
extends PlayerAttack

signal subweapon_despawned

const POINTS_SPRITE_OFFSET:Vector2 = Vector2(0, -16)
const POINTS_1000_FRAME:int = 4
const POINTS_2000_FRAME:int = 5
const POINTS_4000_FRAME:int = 6

@onready var points_graphic:PackedScene = preload("res://scenes/points.tscn")

var direction:int = 1
var num_kills:int = 0

func _on_area_entered(area:Area2D) -> void:
	super._on_area_entered(area)
	if(area is not Hitbox):
		return
	Globals.game_instance.increase_subweapon_hits()
	var hitbox:Hitbox = area
	if(!is_instance_valid(hitbox.health_component)):
		return
	if(!hitbox.has_processed_hit):
		await hitbox.processed_hit
	if(hitbox.health_component.remaining_hp <= 0):
		num_kills += 1
	else:
		return
	var new_points_graphic:Sprite2D
	var num_points:int = 0
	match(num_kills):
		0, 1:
			return
		2:
			new_points_graphic = points_graphic.instantiate()
			new_points_graphic.frame = POINTS_1000_FRAME
			num_points = 1000
		3:
			new_points_graphic = points_graphic.instantiate()
			new_points_graphic.frame = POINTS_2000_FRAME
			num_points = 2000
		4:
			new_points_graphic = points_graphic.instantiate()
			new_points_graphic.frame = POINTS_4000_FRAME
			num_points = 4000
	if(is_instance_valid(new_points_graphic)):
		add_sibling(new_points_graphic)
		new_points_graphic.global_position = hitbox.global_position + POINTS_SPRITE_OFFSET
	Globals.game_instance.score += num_points
	Globals.game_instance.score_changed.emit(Globals.game_instance.score)
func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		subweapon_despawned.emit()
