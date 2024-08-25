class_name Hitbox
extends Area2D

@export var health_component:HealthComponent
@export var awarded_points:int = 0

signal got_hit(attacker:Hurtbox)

func _on_area_entered(area) -> void:
	if(area is not Hurtbox):
		return
	if(is_instance_valid(health_component)):
		health_component._decrease_hp(area.damage)
	got_hit.emit(area)

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE && is_instance_valid(health_component) && is_instance_valid(Globals.game_instance) && health_component.remaining_hp <= 0):
		Globals.game_instance.score += awarded_points
		Globals.game_instance.score_changed.emit(Globals.game_instance.score)
