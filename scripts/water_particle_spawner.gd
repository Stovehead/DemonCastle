extends Area2D

@onready var water_particle:PackedScene = preload("res://scenes/water_particle.tscn")

func spawn_particles(pos:Vector2):
	var particle1:CharacterBody2D = water_particle.instantiate()
	particle1.position = pos
	particle1.velocity = Vector2(10, -130)
	var particle2:CharacterBody2D = water_particle.instantiate()
	particle2.position = pos
	particle2.velocity = Vector2(25, -30)
	var particle3:CharacterBody2D = water_particle.instantiate()
	particle3.position = pos
	particle3.velocity = Vector2(-25, -30)
	add_child(particle1)
	add_child(particle2)
	add_child(particle3)


func _on_body_entered(body: Node2D) -> void:
	if(body is CharacterBody2D):
		spawn_particles(Vector2(to_local(body.global_position).x, 0))
		if(body.velocity.y <= 0):
			SfxManager.play_sound_effect(SfxManager.WATER_EXIT)
		else:
			SfxManager.play_sound_effect(SfxManager.WATER_ENTER)
