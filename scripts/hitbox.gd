extends Area2D

@export var health_component:HealthComponent
@export var awarded_points:int = 0

signal got_hit(attacker:Hurtbox)

func _on_area_entered(area):
	if(area is Hurtbox):
		got_hit.emit(area)
		if(is_instance_valid(health_component)):
			health_component._decrease_hp(area.damage)

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		Globals.game_instance.score += awarded_points
		Globals.game_instance.score_changed.emit(Globals.game_instance.score)
