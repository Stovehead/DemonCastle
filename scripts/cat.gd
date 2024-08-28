class_name Cat
extends CharacterBody2D

signal died

const RUN_SPEED:float = 130.0
const JUMP_HEIGHT:float = -100.0
const RANGE:float = 64.0

@onready var sprite:Sprite2D = $Sprite2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var floor_detector:RayCast2D = $FloorDetector
@onready var gravity_component:GravityComponent = $GravityComponent
@onready var flame_spawner:FlameSpawner = $FlameSpawner
@onready var collision:CollisionShape2D = $CollisionShape2D

var activated:bool = false
var in_air:bool = false
var direction:int = 1

func set_direction() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	if(Globals.current_player.global_position.x < global_position.x):
		direction = -1
	else:
		direction = 1
	sprite.flip_h = direction == -1

func detect_player() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	if(abs(Globals.current_player.global_position.x - global_position.x) < RANGE):
		activated = true
		animation_player.play("run")
		velocity.x = RUN_SPEED * direction

func check_floor() -> void:
	if(floor_detector.is_colliding() || in_air):
		return
	in_air = true
	velocity.y = JUMP_HEIGHT
	animation_player.play("jump")
	collision.disabled = true

func check_has_landed() -> void:
	if(!in_air):
		return
	if(floor_detector.is_colliding()):
		collision.disabled = false
		in_air = false
		animation_player.play("run")
		set_direction()
		velocity.x = RUN_SPEED * direction

func _ready() -> void:
	set_direction()

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity(velocity, delta)
	if(!activated):
		detect_player()
		return
	check_floor()
	check_has_landed()
	move_and_slide()

func _on_hp_changed(new_hp:int) -> void:
	if(new_hp <= 0):
		flame_spawner.spawn_flame()
		died.emit()
		queue_free()
		return
