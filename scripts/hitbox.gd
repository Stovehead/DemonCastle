extends Area2D

@export var health_component:HealthComponent

signal got_hit(attacker:Hurtbox)

func _on_area_entered(area):
	if(area is Hurtbox):
		got_hit.emit(area)
		health_component._decrease_hp(area.damage)
