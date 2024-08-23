class_name BreakableBlock
extends Hitbox

signal whip_exited

const PARTICLE_X_VELOCITY_RANGE:Vector2 = Vector2(25, 50)
const PARTICLE_Y_VELOCITY_RANGE:Vector2 = Vector2(-100, -150)

@onready var particle:PackedScene = preload("res://scenes/particle.tscn")
@onready var particle_texture:Texture = preload("res://media/graphics/broken_block_particle.png")
@export var item_to_drop:PackedScene

func spawn_particle(pos:Vector2, velocity:Vector2) -> void:
	var new_particle:Particle = particle.instantiate()
	new_particle.velocity = velocity
	add_sibling(new_particle)
	new_particle.global_position = pos
	new_particle.sprite.texture = particle_texture

func _on_got_hit(attacker: Hurtbox) -> void:
	if(attacker is Whip):
		spawn_particle(global_position, Vector2(randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
		spawn_particle(global_position, Vector2(randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
		spawn_particle(global_position, Vector2(-randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
		spawn_particle(global_position, Vector2(-randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
	if(is_instance_valid(item_to_drop)):
		var new_item:Node2D = item_to_drop.instantiate()
		add_sibling.call_deferred(new_item)
		new_item.set_deferred("global_position", global_position)
	visible = false

func _on_area_exited(area: Area2D) -> void:
	if(area is Whip):
		whip_exited.emit()
		queue_free()
