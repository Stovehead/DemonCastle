class_name PlayerAttack
extends Hurtbox

@onready var hit_spark:PackedScene = preload("res://scenes/hit_spark.tscn")

func _on_area_entered(area:Area2D):
	SfxManager.play_sound_effect_no_overlap(SfxManager.HIT)
	var new_spark = hit_spark.instantiate()
	new_spark.global_position.y = global_position.y
	if(global_position.x > area.global_position.x):
		new_spark.global_position.x = area.global_position.x + 8
	else:
		new_spark.global_position.x = area.global_position.x - 8
	Globals.game_instance.current_stage.add_child(new_spark)
