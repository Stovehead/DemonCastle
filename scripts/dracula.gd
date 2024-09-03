class_name Dracula
extends Node2D

const TELEPORT_RADIUS:float = 160.0

var head_flashing:bool = false
var body_flashing:bool = false

@onready var head_sprite:Sprite2D = $Head
@onready var body_sprite:Sprite2D = $Body
@onready var fireball_spawner:DraculaFireballSpawner = $FireballSpawner
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var teleport_timer:Timer = $TeleportTimer
@onready var hurtbox:Hurtbox = $Hurtbox

func face_player() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	var direction:int = -1 if Globals.current_player.global_position.x < global_position.x else 1
	scale.x = direction

func start_head_flashing() -> void:
	head_flashing = true

func stop_head_flashing() -> void:
	head_flashing = false
	head_sprite.modulate.a = 1

func start_body_flashing() -> void:
	body_flashing = true

func stop_body_flashing() -> void:
	body_flashing = false
	body_sprite.modulate.a = 1

func spawn_fireballs() -> void:
	var target:Vector2 = global_position
	if(is_instance_valid(Globals.current_player)):
		target = Globals.current_player.position
		target.y += Player.DEFAULT_COLLISION_SIZE.y/4
	fireball_spawner.spawn_fireballs(target)

func appear() -> void:
	head_sprite.visible = false
	body_sprite.visible = false
	visible = true
	animation_player.play("appear")

func start_teleport_timer() -> void:
	teleport_timer.start()

func disable_hurtbox() -> void:
	hurtbox.monitorable = false
	hurtbox.set_collision_layer_value(3, false)
	$Hurtbox/CollisionShape2D.disabled = true

func enable_hurtbox() -> void:
	hurtbox.monitorable = true
	hurtbox.set_collision_layer_value(3, true)
	$Hurtbox/CollisionShape2D.disabled = false

func _process(_delta: float) -> void:
	if(head_flashing):
		head_sprite.modulate.a = 1 - head_sprite.modulate.a
	if(body_flashing):
		if(head_flashing):
			body_sprite.modulate.a = head_sprite.modulate.a
		else:
			body_sprite.modulate.a = 1 - body_sprite.modulate.a

func _physics_process(_delta: float) -> void:
	face_player()
	print(teleport_timer.time_left)

func _on_teleport_timer_timeout() -> void:
	var teleport_position:Vector2 = global_position
	if(is_instance_valid(Globals.game_instance)):
		teleport_position.x = Globals.game_instance.camera.get_screen_center_position().x + randf_range(-TELEPORT_RADIUS, TELEPORT_RADIUS)
	global_position = teleport_position
	animation_player.play("attack")
