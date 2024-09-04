class_name Dracula
extends Node2D

const TELEPORT_RADIUS:float = 160.0
const HEAD_FLY_VELOCITY:Vector2 = Vector2(-160, -300)
const DEFAULT_HEAD_POSITION:Vector2 = Vector2(0, -27)
const HEAD_OFFSET:float = 3
const DIAGONAL_PARTICLE_VELOCITY = Vector2(168, 168)
const HORIZONTAL_PARTICLE_VELOCITY = Vector2(264, 0)
const COOKIE_MONSTER_SPAWN_DELAY:float = 0.283
const COOKIE_MONSTER_SPAWN_OFFSET:Vector2 = Vector2(0, -1)

var head_flashing:bool = false
var body_flashing:bool = false
var active:bool = true

@export var magic_crystal_spawner:MagicCrystalSpawner

@onready var head_sprite:Sprite2D = $Head
@onready var body_sprite:Sprite2D = $Body
@onready var fireball_spawner:DraculaFireballSpawner = $FireballSpawner
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var teleport_timer:Timer = $TeleportTimer
@onready var hurtbox:Hurtbox = $Hurtbox
@onready var hitbox:Hitbox = $Hitbox
@onready var health_component:HealthComponent = $HealthComponent
@onready var death_timer:Timer = $DeathTimer
@onready var particle_scene:PackedScene = preload("res://scenes/particle.tscn")
@onready var particle_sprite:Texture = preload("res://media/graphics/dracula_particle.png")
@onready var phase_2_music:AudioStream = preload("res://media/music/blacknight.ogg")
@onready var cookie_monster_scene:PackedScene = preload("res://scenes/cookie_monster.tscn")

func face_player() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	if(active):
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
		target = Globals.current_player.global_position
	fireball_spawner.spawn_fireballs(target)

func appear() -> void:
	head_sprite.visible = false
	body_sprite.visible = false
	visible = true
	animation_player.play("appear")

func start_teleport_timer() -> void:
	teleport_timer.start()

func notify_hitboxes() -> void:
	for area in hurtbox.get_overlapping_areas():
		if(area is Hitbox):
			area.area_entered.emit(hurtbox)

func disable_hurtbox() -> void:
	hurtbox.set_deferred("monitorable", false)
	hitbox.set_deferred("monitoring", false)
	hitbox.set_deferred("monitorable", false)

func enable_hurtbox() -> void:
	hurtbox.set_deferred("monitorable", true)
	hitbox.set_deferred("monitoring", true)
	hitbox.set_deferred("monitorable", true)
	notify_hitboxes.call_deferred()

func spawn_particle(velocity:Vector2, velocity_scale:Vector2, flip_h:bool) -> void:
	var new_particle:Particle = particle_scene.instantiate()
	new_particle.velocity = velocity
	new_particle.velocity.x *= velocity_scale.x
	new_particle.velocity.y *= velocity_scale.y
	new_particle.gravity_enabled = false
	add_sibling(new_particle)
	new_particle.global_position = global_position
	new_particle.sprite.texture = particle_sprite
	new_particle.sprite.flip_h = flip_h

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

func _on_teleport_timer_timeout() -> void:
	var teleport_position:Vector2 = global_position
	if(is_instance_valid(Globals.game_instance)):
		teleport_position.x = Globals.game_instance.camera.get_screen_center_position().x + randf_range(-TELEPORT_RADIUS, TELEPORT_RADIUS)
	global_position = teleport_position
	animation_player.play("attack")

func _on_hitbox_got_hit(_attacker: Hurtbox) -> void:
	var scaled_health:int = int(health_component.remaining_hp/2.0 + 0.5)
	Globals.game_instance.enemy_hp_changed.emit(scaled_health, false)
	if(health_component.remaining_hp <= 0):
		animation_player.pause()
		head_sprite.position = Vector2(0, -27)
		stop_body_flashing()
		stop_head_flashing()
		head_sprite.visible = true
		body_sprite.visible = true
		active = false
		disable_hurtbox()
		head_sprite.visible = false
		var head_particle:Particle = particle_scene.instantiate()
		head_particle.velocity = HEAD_FLY_VELOCITY
		if(scale.x == -1):
			head_particle.velocity.x *= -1
		add_sibling(head_particle)
		head_particle.sprite.texture = head_sprite.texture
		head_particle.global_position.x = head_sprite.global_position.x + HEAD_OFFSET * scale.x
		head_particle.global_position.y = head_sprite.global_position.y
		head_particle.scale.x = -scale.x
		death_timer.start()

func _on_death_timer_timeout() -> void:
	if(is_instance_valid(Globals.game_instance)):
		Globals.game_instance.music_player.stream = phase_2_music
		Globals.game_instance.music_player.play()
	spawn_particle(DIAGONAL_PARTICLE_VELOCITY, Vector2(1, 1), false)
	spawn_particle(HORIZONTAL_PARTICLE_VELOCITY, Vector2(1, 1), false)
	spawn_particle(DIAGONAL_PARTICLE_VELOCITY, Vector2(1, -1), false)
	spawn_particle(DIAGONAL_PARTICLE_VELOCITY, Vector2(-1, -1), true)
	spawn_particle(HORIZONTAL_PARTICLE_VELOCITY, Vector2(-1, 1), true)
	spawn_particle(DIAGONAL_PARTICLE_VELOCITY, Vector2(-1, 1), true)
	body_sprite.visible = false
	await get_tree().create_timer(COOKIE_MONSTER_SPAWN_DELAY, false, true).timeout
	var cookie_monster_instance:CookieMonster = cookie_monster_scene.instantiate()
	if(is_instance_valid(magic_crystal_spawner)):
		cookie_monster_instance.magic_crystal_spawner = magic_crystal_spawner
	add_sibling(cookie_monster_instance)
	cookie_monster_instance.global_position = global_position + COOKIE_MONSTER_SPAWN_OFFSET
	cookie_monster_instance.face_player()
	queue_free()
