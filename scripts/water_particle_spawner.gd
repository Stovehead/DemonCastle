extends Area2D

const PARTICLE_VELOCITIES:Array = [Vector2(10, -130), Vector2(25, -30), Vector2(-25, -30)]

@onready var particle:PackedScene = preload("res://scenes/particle.tscn")
@onready var water_particle_texture:Texture = preload("res://media/graphics/water_particle.png")

func spawn_particle(pos:Vector2, velocity:Vector2):
	var particle1:Particle = particle.instantiate()
	particle1.velocity = velocity
	add_child(particle1)
	particle1.global_position = pos
	particle1.sprite.texture = water_particle_texture

func spawn_particles(pos:Vector2):
	for particle_velocity:Vector2 in PARTICLE_VELOCITIES:
		spawn_particle(pos, particle_velocity)

func _on_body_entered(body: Node2D) -> void:
	if(body is not CharacterBody2D):
		return
	spawn_particles(Vector2(body.global_position.x, global_position.y))
	if(body.velocity.y <= 0):
		SfxManager.play_sound_effect_no_overlap(SfxManager.WATER_EXIT)
	else:
		SfxManager.play_sound_effect_no_overlap(SfxManager.WATER_ENTER)
