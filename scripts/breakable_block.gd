class_name BreakableBlock
extends Hitbox

signal whip_exited

const PARTICLE_MIN_X_VELOCITY:int = 25
const PARTICLE_MAX_X_VELOCITY:int = 50
const PARTICLE_MIN_Y_VELOCITY:int = -100
const PARTICLE_MAX_Y_VELOCITY:int = -150
const PARTICLE_X_VELOCITY_RANGE:Vector2 = Vector2(PARTICLE_MIN_X_VELOCITY, PARTICLE_MAX_X_VELOCITY)
const PARTICLE_Y_VELOCITY_RANGE:Vector2 = Vector2(PARTICLE_MIN_Y_VELOCITY, PARTICLE_MAX_Y_VELOCITY)

@onready var particle:PackedScene = preload("res://scenes/particle.tscn")
@onready var particle_texture:Texture = preload("res://media/graphics/broken_block_particle.png")
@onready var persistent_component:PersistentObject = $PersistentObject
@export var item_to_drop:PackedScene

var broken = false

func spawn_particle(pos:Vector2, velocity:Vector2) -> void:
	var new_particle:Particle = particle.instantiate()
	new_particle.velocity = velocity
	add_sibling(new_particle)
	new_particle.global_position = pos
	new_particle.sprite.texture = particle_texture

func spawn_block_particles() -> void:
	spawn_particle(global_position, Vector2(randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
	spawn_particle(global_position, Vector2(randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
	spawn_particle(global_position, Vector2(-randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))
	spawn_particle(global_position, Vector2(-randf_range(PARTICLE_X_VELOCITY_RANGE.x, PARTICLE_X_VELOCITY_RANGE.y), randf_range(PARTICLE_Y_VELOCITY_RANGE.x, PARTICLE_Y_VELOCITY_RANGE.y)))

func spawn_item() -> void:
	var new_item:Node2D = item_to_drop.instantiate()
	add_sibling.call_deferred(new_item)
	new_item.set_deferred("global_position", global_position)

func _ready() -> void:
	if(broken):
		monitoring = false

func _on_persistent_object_retreived_data(variables: Dictionary) -> void:
	if(variables.has("broken")):
		broken = variables.broken

func _on_got_hit(attacker: Hurtbox) -> void:
	if(attacker is not Whip):
		return
	var whip:Whip = attacker
	if(is_instance_valid(whip.current_sfx)):
		SfxManager.stop_sound_effect(whip.current_sfx)
	SfxManager.play_sound_effect_no_overlap(SfxManager.BLOCK_BREAK)
	persistent_component.variables.broken = true
	var is_item_drop:bool = is_instance_valid(item_to_drop)
	spawn_block_particles()
	if(is_item_drop):
		spawn_item()
	visible = false

func _on_area_exited(area: Area2D) -> void:
	if(area is not Whip):
		return
	whip_exited.emit()
	queue_free()
