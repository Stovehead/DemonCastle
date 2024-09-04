class_name Player
extends CharacterBody2D

enum Subweapons{
	NONE,
	KNIFE,
	AXE,
	CROSS,
	HOLY_WATER,
	STOPWATCH
}

var subweapon_scenes:Array = [
	null,
	preload("res://scenes/knife.tscn"),
	preload("res://scenes/axe.tscn"),
	preload("res://scenes/cross.tscn"),
	preload("res://scenes/holy_water.tscn"),
	null,
]

signal hp_changed(new_hp:int, instant:bool)
signal hearts_changed(new_hearts:int)
signal subweapon_changed(new_subweapon:int)
signal max_subweapons_changed(new_max_subweapons:int)
signal time_stopped
signal died

const ACCELERATION:float = 1200
const MAX_SPEED:float = 60
const JUMP_SPEED:float = -185
const TERMINAL_VELOCITY:float = 360
const MIN_STUN_HEIGHT:float = 63
const MIN_BORDER_DISTANCE:float = 8
const KNOCKBACK_VELOCITY:Vector2 = Vector2(60, -130)
const DEFAULT_COLLISION_SIZE = Vector2(15, 30)
const SMALL_COLLISION_SIZE = Vector2(15, 23)
const STOPWATCH_COST:int = 5
const DEFAULT_PALETTE:Array[Vector4] = [Vector4(0.337, 0.114, 0, 1), Vector4(0.918, 0.620, 0.133, 1), Vector4(0.969, 0.847, 0.647, 1)]
const INVINCIBLE_PALETTE:Array[Vector4] = [Vector4(0.753, 0.875, 1, 1), Vector4(0.969, 0.847, 0.647, 1), Vector4(0.918, 0.620, 0.133, 1)]
const INVINCIBLE_TIME_1:float = 1.73333
const INVINCIBLE_TIME_2:float = 2.13333
const NUM_STARTING_HEARTS:int = 5

var player_direction:int = 1:
	set(new_player_direction):
		if(new_player_direction != player_direction):
			player_direction = new_player_direction
var player_has_control:bool = true
var can_move_horizontally:bool = true
var cutscene_control:bool = false
var cutscene_move_direction:int = 1
var cutscene_move_speed_factor:float = 1
var queued_jump:bool = false
var queued_whip:bool = false
var is_jumping:bool = false
var is_falling:bool = false
var is_whipping:bool = false
var is_damaged:bool = false
var is_crouching:bool = false
var last_grounded_y:float = 0
var whip_level:int = 1
var num_hearts:int = NUM_STARTING_HEARTS
var current_subweapon:int = 0
var max_num_subweapons:int = 1
var num_existing_subweapons:int = 0
var new_subweapon:Subweapon = null

var on_stairs:bool = false
var in_stair_bottom:bool = false
var in_stair_top:bool = false
var current_stair:Stairs
var going_up_stairs:bool = false
var next_step:float
var current_step:int
var just_warped:bool = false
var floor_checker:ShapeCast2D

var is_hurt:bool = false
var is_dead:bool = false
var time_up:bool = false
var is_invincible:bool = false
var is_time_stopped:bool = false

@onready var collision:CollisionShape2D = $Collision
@onready var jump_timer:Timer = $JumpTimer
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite
@onready var whip:Whip = $Whip
@onready var whip_animation_player:AnimationPlayer = $Whip/AnimationPlayer
@onready var stun_timer:Timer = $StunTimer
@onready var jump_blocker_l:RayCast2D = $JumpBlockerL
@onready var jump_blocker_r:RayCast2D = $JumpBlockerR
@onready var invulnerability_timer:Timer = $InvulnerabilityTimer
@onready var hitbox:Area2D = $Hitbox
@onready var stair_stun_timer:Timer = $StairStunTimer
@onready var whip_upgrade_pauser:Node = $WhipUpgradePauser

@onready var gravity_component:GravityComponent = $GravityComponent
@onready var health_component:HealthComponent = $HealthComponent
@onready var game:Game = Globals.game_instance

@onready var palette_swap_shader:Shader = preload("res://shaders/palette_swap.gdshader")

func reset_variables() -> void:
	player_has_control = true
	can_move_horizontally = true
	cutscene_control = false
	queued_jump = false
	queued_whip = false
	is_jumping = false
	is_falling = false
	is_whipping = false
	is_damaged = false
	is_crouching = false
	last_grounded_y = global_position.y
	num_hearts = NUM_STARTING_HEARTS
	num_existing_subweapons = 0
	new_subweapon = null
	on_stairs = false
	in_stair_bottom = false
	in_stair_top = false
	going_up_stairs = false
	just_warped = false
	is_hurt = false
	is_dead = false
	time_up = false
	is_invincible = false
	is_time_stopped = false
	whip.visible = false
	whip.reset()
	whip.collision.disabled = true
	animation_player.play("idle")
	velocity = Vector2.ZERO
	sprite.frame = 0

func emit_signals() -> void:
	hp_changed.emit(health_component.remaining_hp, true)
	hearts_changed.emit(num_hearts)
	subweapon_changed.emit(current_subweapon)
	max_subweapons_changed.emit(max_num_subweapons)

func start_invincibility() -> void:
	if(is_invincible):
		return
	is_invincible = true
	hitbox.set_collision_mask_value(3, false)
	SfxManager.play_sound_effect(SfxManager.INVINCIBLE)
	await get_tree().create_timer(INVINCIBLE_TIME_1, false, true).timeout
	apply_invincible_palette()
	await get_tree().create_timer(INVINCIBLE_TIME_2, false, true).timeout
	reset_sprite_shader()
	SfxManager.play_sound_effect(SfxManager.INVINCIBILITY_RUNNING_OUT)
	await get_tree().create_timer(INVINCIBLE_TIME_2, false, true).timeout
	is_invincible = false
	modulate.a = 1
	if(!is_dead && !is_hurt):
		hitbox.set_collision_mask_value(3, true)

func apply_invincible_palette() -> void:
	sprite.material.shader = palette_swap_shader

func reset_sprite_shader() -> void:
	sprite.material.shader = null

func get_weapon_to_attack() -> int:
	if(current_subweapon == Subweapons.NONE || num_existing_subweapons >= max_num_subweapons):
		return Subweapons.NONE
	return current_subweapon

func play_stair_attack_animation() -> void:
	if(player_direction == current_stair.direction):
		animation_player.play("stair_up_whip")
	else:
		animation_player.play("stair_down_whip")
	velocity = Vector2.ZERO

func play_floor_attack_animation() -> void:
	if(is_crouching && is_on_floor()):
		animation_player.play("crouch_whip")
		return
	animation_player.play("whip")
	if(collision.shape.get_rect().size.y < DEFAULT_COLLISION_SIZE.y):
		global_position.y -= (DEFAULT_COLLISION_SIZE.y - collision.shape.get_rect().size.y)/2

func create_subweapon(attack:int) -> void:
	num_hearts -= 1
	hearts_changed.emit(num_hearts)
	var subweapon_to_load:PackedScene = subweapon_scenes[attack]
	if(subweapon_to_load != null):
		new_subweapon = subweapon_to_load.instantiate()
		new_subweapon.direction = player_direction
		new_subweapon.subweapon_despawned.connect(_on_subweapon_despawned)

func do_stopwatch() -> void:
	is_time_stopped = true
	time_stopped.emit()
	num_hearts -= STOPWATCH_COST
	hearts_changed.emit(num_hearts)

func do_attack() -> void:
	if(on_stairs):
		play_stair_attack_animation()
	else:
		play_floor_attack_animation()
	var attack:int = get_weapon_to_attack()
	if(attack == Subweapons.NONE || attack == Subweapons.STOPWATCH || !Input.is_action_pressed("up") || num_hearts <= 0 || !can_move_horizontally):
		whip.play_animation()
		if(attack == Subweapons.STOPWATCH && num_hearts >= STOPWATCH_COST && Input.is_action_pressed("up") && !is_time_stopped && can_move_horizontally):
			do_stopwatch()
	else:
		create_subweapon(attack)
	is_whipping = true
	queued_whip = false

func activate_subweapon() -> void:
	if(new_subweapon == null):
		return
	add_sibling(new_subweapon)
	new_subweapon.global_position = global_position
	num_existing_subweapons += 1
	new_subweapon = null

func can_jump() -> bool:
	return !jump_blocker_l.is_colliding() && !jump_blocker_r.is_colliding() && !is_crouching

func horizontal_movement(input_direction:float, speed_factor:float, delta:float) -> void:
	# Set velocity to positive so that it's easier to work with
	velocity.x = abs(velocity.x)
	# If moving
	if(input_direction != 0 && !is_whipping && !is_crouching):
		velocity.x += ACCELERATION * delta
	# If not moving
	else:
		velocity.x -= ACCELERATION * delta
	velocity.x = clamp(velocity.x, 0, MAX_SPEED * speed_factor)
	if(input_direction != 0 && !is_whipping):
		player_direction = input_direction
	velocity.x *= input_direction

func cutscene_movement(delta:float) -> void:
	horizontal_movement(cutscene_move_direction, cutscene_move_speed_factor, delta)
	is_crouching = false
	stun_timer.stop()
	is_hurt = false

func check_attack_input() -> void:
	if(!Input.is_action_just_pressed("attack")):
		return
	if(is_whipping || is_hurt):
		return
	# Can't whip immediately on stairs
	if(on_stairs):
		queued_whip = true
	else:
		do_attack()

func go_up_stairs() -> void:
	# If reached a step
	if(!Globals.crossed_point(global_position.x, next_step, get_position_delta().x)):
		# Move the player to the next step
		velocity = Vector2(30 * player_direction, 30 * player_direction * -current_stair.direction)
		return
	if(just_warped):
		just_warped = false
		return
	global_position.x = next_step
	going_up_stairs = false
	current_step += current_stair.direction * player_direction

# Returns true if just stair transitioned
func get_off_stairs() -> bool:
	if(current_stair is TransitionalStairs && current_step == current_stair.height * current_stair.target):
		current_stair.transition(self)
		return true
	on_stairs = false
	global_position.x = current_stair.global_position.x + Stairs.SINGLE_STAIR_HEIGHT * current_step * player_direction
	global_position.y -= 1
	velocity.y = 100
	animation_player.play("idle")
	return false

func go_to_idle_on_stairs() -> void:
	velocity = Vector2.ZERO
	if(is_whipping):
		return
	if(player_direction == current_stair.direction):
		animation_player.play("stair_up_idle")
	else:
		animation_player.play("stair_down_idle")

func start_moving_up_stairs(direction:int, animation:String) -> void:
	going_up_stairs = true
	animation_player.play(animation)
	player_direction = current_stair.direction * direction
	next_step = next_step + Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction * direction

func stop_on_stairs(just_stair_transitioned: bool) -> void:
	# If reached top/bottom
	if(current_step <= 0 || current_step >= current_stair.height):
		just_stair_transitioned = get_off_stairs()
	if(just_stair_transitioned || !on_stairs):
		return
	# Do the whip that was queued earlier
	if(queued_whip):
		do_attack()
		return
	var vertical_input_direction:int = Input.get_axis("down", "up")
	var horizontal_input_direction:int = Input.get_axis("left", "right") * current_stair.direction
	# If not holding a direction
	if(vertical_input_direction == 0 && horizontal_input_direction == 0):
		go_to_idle_on_stairs()
		return
	# Start moving up stairs
	if(vertical_input_direction == 1 || horizontal_input_direction == 1):
		start_moving_up_stairs(1, "stair_up")
	elif(vertical_input_direction == -1 || horizontal_input_direction == -1):
		start_moving_up_stairs(-1, "stair_down")

func stair_movement() -> void:
	var just_stair_transitioned:bool = false
	last_grounded_y = global_position.y
	if(time_up):
		fall_off_stairs()
		return
	if(is_whipping):
		return
	# Moving
	if(going_up_stairs):
		go_up_stairs()
	# If stopped on stairs
	# Need to check again in case they just stopped
	if(!going_up_stairs):
		stop_on_stairs(just_stair_transitioned)

func check_crouch_input() -> void:
	if(Input.is_action_just_pressed("down") && !in_stair_top):
		is_crouching = true
	if(Input.is_action_just_released("down") && stun_timer.is_stopped()):
		is_crouching = false

func check_jump_input() -> void:
	if(Input.is_action_just_pressed("jump") && can_jump()):
		queued_jump = true
		jump_timer.start()

func get_on_stair(step:int, direction:int, animation:String, step_position:float) -> void:
	current_step = step
	global_position.x = step_position
	next_step = step_position + Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction * direction
	on_stairs = true
	going_up_stairs = true
	player_direction = current_stair.direction * direction
	animation_player.play(animation)
	queued_jump = false
	jump_timer.stop()

func move_towards_stair(delta:float, step:int, is_in_stair:bool, direction:int, step_position:float, animation:String) -> bool:
	if(!is_in_stair || is_whipping || is_jumping || !is_on_floor()):
		return false
	if(Globals.crossed_point(global_position.x, step_position, get_position_delta().x)):
		get_on_stair(step, direction, animation, step_position)
		return true
	# Move towards stair
	horizontal_movement(sign(step_position - global_position.x), 1, delta)
	return true

func check_stair_bottom(delta:float) -> bool:
	if(!Input.is_action_pressed("up")):
		return false
	if(!is_instance_valid(current_stair)):
		return false
	return move_towards_stair(delta, 0, in_stair_bottom, 1, current_stair.global_position.x, "stair_up")

func check_stair_top(delta:float) -> bool:
	if(!Input.is_action_pressed("down")):
		return false
	if(!is_instance_valid(current_stair)):
		return false
	var top_stair_position:float = current_stair.global_position.x + current_stair.height * Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
	return move_towards_stair(delta, current_stair.height, in_stair_top, -1, top_stair_position, "stair_down")

func check_stun() -> void:
	if(global_position.y - last_grounded_y >= MIN_STUN_HEIGHT && !is_whipping):
		stun_timer.start()
		is_crouching = true
		SfxManager.play_sound_effect(SfxManager.FALL)
	last_grounded_y = global_position.y

func check_time_up() -> bool:
	if(time_up):
		die()
		return true
	return false

func hit_floor_after_hit() -> void:
	if(health_component.remaining_hp > 0):
		player_direction = -player_direction
		is_hurt = false
		stun_timer.start()
		is_crouching = true
		invulnerability_timer.start()
	else:
		die()

func check_horizontal_input(delta:float) -> void:
	var input_direction:int = Input.get_axis("left", "right")
	if(is_crouching):
		horizontal_movement(0, 1, delta)
	else:
		horizontal_movement(input_direction, 1, delta)

func start_jump() -> void:
	queued_jump = false
	is_jumping = true
	jump_timer.stop()
	velocity.y = JUMP_SPEED
	animation_player.play("jump")

func floor_movement(delta:float, did_horizontal_movement:bool) -> void:
	is_jumping = false
	is_falling = false
	# Stunning
	check_stun()
	if(check_time_up()):
		stop_movement(delta)
		return
	elif(is_hurt && velocity.y >= 0 && !is_dead):
		hit_floor_after_hit()
	# Horizontal movement
	if(!did_horizontal_movement && !is_hurt && !is_dead):
		if(can_move_horizontally):
			check_horizontal_input(delta)
		else:
			stop_movement(delta)
	# Jumping
	if(queued_jump && !is_whipping && !on_stairs && stun_timer.is_stopped()):
		start_jump()

func check_floor_checker() -> void:
	if(!is_instance_valid(floor_checker)):
		return
	if(is_hurt):
		return
	if(floor_checker.is_colliding()):
		return
	set_collision_mask_value(2, true)
	floor_checker.queue_free()

func start_falling() -> void:
	if(animation_player.assigned_animation == "walk"):
		animation_player.play("idle")
	if(!is_falling):
		is_falling = true
		velocity.y = TERMINAL_VELOCITY
	velocity.x = 0

func air_movement() -> void:
	if(!is_jumping && !is_hurt):
		start_falling()
	check_floor_checker()

func normal_movement(delta:float) -> void:
	var did_horizontal_movement:bool = false
	# Getting on stairs
	if(check_stair_bottom(delta)):
		did_horizontal_movement = true
	elif(check_stair_top(delta)):
		did_horizontal_movement = true
	else:
		# Crouching
		check_crouch_input()
		# Jump timer
		check_jump_input()

	if(is_on_floor()):
		floor_movement(delta, did_horizontal_movement)
		return
	air_movement()

func stop_movement(delta:float) -> void:
	if(is_on_floor()):
		horizontal_movement(0, 1, delta) 
		is_crouching = false
		stun_timer.stop()

func handle_input(delta:float) -> void:
	if(is_dead):
		stop_movement(delta)
		return
	if(!player_has_control):
		if(cutscene_control):
			cutscene_movement(delta)
			return
		stop_movement(delta)
		return
	if(player_has_control && !is_dead):
		# Attacking
		check_attack_input()
		# Movement on stairs
		if(on_stairs && stair_stun_timer.is_stopped()):
			stair_movement()
		# Non-stair movement
		# Need to check again in case the player got off stairs
		if(!on_stairs):
			normal_movement(delta)

func die_with_animation(animation:String) -> void:
	died.emit()
	if(animation_player.current_animation == "idle" || time_up):
		player_direction *= -1
	animation_player.play(animation)
	is_dead = true
	hitbox.monitoring = false
	set_collision_layer_value(1, false)

func die() -> void:
	die_with_animation("death")

func fall_off_stairs() -> void:
	on_stairs = false
	velocity = Vector2(0, TERMINAL_VELOCITY)
	whip_animation_player.play("RESET")
	animation_player.play("idle")
	stair_stun_timer.stop()
	is_hurt = true
	floor_checker = ShapeCast2D.new()
	floor_checker.position = Vector2.ZERO
	floor_checker.enabled = true
	floor_checker.target_position = Vector2.ZERO
	floor_checker.set_collision_mask_value(1, false)
	floor_checker.set_collision_mask_value(2, true)
	floor_checker.shape = RectangleShape2D.new()
	floor_checker.shape.size = DEFAULT_COLLISION_SIZE
	add_child(floor_checker)
	floor_checker.force_shapecast_update()
	if(floor_checker.is_colliding()):
		set_collision_mask_value(2, false)

func death_barrier() -> void:
	died.emit()
	velocity.x = 0
	is_dead = true
	hitbox.monitoring = false
	set_collision_layer_value(1, false)
	visible = false

func handle_animation() -> void:
	if(animation_player.assigned_animation == "whip" || animation_player.assigned_animation == "crouch_whip"):
		if(!is_whipping):
			animation_player.play("idle")
	if(animation_player.assigned_animation == "jump"):
		if(is_on_floor()):
			animation_player.play("idle")
			if(collision.shape.get_rect().size.y < DEFAULT_COLLISION_SIZE.y):
				global_position.y -= (DEFAULT_COLLISION_SIZE.y - collision.shape.get_rect().size.y)/2
	if(animation_player.assigned_animation == "crouch"):
		if(!is_crouching):
			animation_player.play("idle")
	if(animation_player.assigned_animation == "idle"):
		if(is_on_floor()):
			if(is_crouching):
				animation_player.play("crouch")
			elif(velocity.x != 0):
				animation_player.play("walk")
	if(animation_player.assigned_animation == "walk"):
		if(is_on_floor()):
			if(is_crouching):
				animation_player.play("crouch")
			elif(velocity.x == 0):
				animation_player.play("idle")
	if(animation_player.assigned_animation == "hurt"):
		if(is_on_floor()):
			animation_player.play("crouch")
	if(player_direction == -1):
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	whip.scale.x = -player_direction

func move_in_bounds() -> void:
	var limit_left:int = Globals.game_instance.camera.limit_left
	var limit_right:int = Globals.game_instance.camera.limit_right
	global_position.x = clamp(global_position.x, limit_left + MIN_BORDER_DISTANCE, limit_right - MIN_BORDER_DISTANCE)

func do_flashing() -> void:
	if(!invulnerability_timer.is_stopped() || is_invincible):
		modulate.a =  1 - modulate.a

func update_hitbox() -> void:
	for area in hitbox.get_overlapping_areas():
		if(area is Hurtbox):
			hitbox.area_entered.emit(area)

func stop_invulnerability() -> void:
	modulate.a = 1
	hitbox.set_collision_mask_value(3, true)
	hitbox.set_deferred("monitoring", true)
	update_hitbox.call_deferred()

func _ready() -> void:
	animation_player.play("idle")
	last_grounded_y = global_position.y
	sprite.material = ShaderMaterial.new()
	sprite.material.set_shader_parameter("original_palette", DEFAULT_PALETTE)
	sprite.material.set_shader_parameter("new_palettes", INVINCIBLE_PALETTE)
	sprite.material.set_shader_parameter("num_new_palettes", 1)

func _process(_delta: float) -> void:
	do_flashing()

func _physics_process(delta:float) -> void:
	handle_input(delta)
	if(on_stairs):
		collision.disabled = true
	else:
		collision.disabled = false
		velocity = gravity_component.apply_gravity_with_terminal_velocity(velocity, TERMINAL_VELOCITY, delta)
	var old_velocity = velocity.x
	move_and_slide()
	velocity.x = old_velocity
	handle_animation()
	move_in_bounds()

func _on_jump_timer_timeout() -> void:
	queued_jump = false

func _on_animation_player_animation_finished(anim_name) -> void:
	if(anim_name == "whip" || anim_name == "crouch_whip" || anim_name == "stair_up_whip" || anim_name == "stair_down_whip"):
		is_whipping = false

func _on_hitbox_area_entered(area:Area2D) -> void:
	if(area is Upgrade):
		area.do_upgrade(self)
	elif(area.is_in_group("stairs")):
		if(area.is_in_group("stairs_bottom")):
			in_stair_bottom = true
			current_stair = area.get_parent()
		elif(area.is_in_group("stairs_top")):
			in_stair_top = true
			current_stair = area.get_parent()

func _on_hitbox_area_exited(area) -> void:
	if(area.is_in_group("stairs")):
		if(area.is_in_group("stairs_bottom")):
			in_stair_bottom = false
		elif(area.is_in_group("stairs_top")):
			in_stair_top = false

func _on_stun_timer_timeout() -> void:
	if(!Input.is_action_pressed("down")):
		is_crouching = false

func _on_hitbox_got_hit(attacker:Hurtbox) -> void:
	SfxManager.play_sound_effect(SfxManager.HURT)
	if(new_subweapon != null):
		new_subweapon.queue_free()
		new_subweapon = null
	hitbox.set_collision_mask_value(3, false)
	if(on_stairs):
		stair_stun_timer.start()
		animation_player.speed_scale = 0
		whip_animation_player.speed_scale = 0
		whip.set_deferred("monitorable", false)
		velocity = Vector2.ZERO
	else:
		whip.visible = false
		whip.reset()
		if(global_position.x > attacker.global_position.x):
			player_direction = 1
		else:
			player_direction = -1
		velocity.x = KNOCKBACK_VELOCITY.x * player_direction
		velocity.y = KNOCKBACK_VELOCITY.y
		is_hurt = true
		is_whipping = false
		animation_player.play("hurt")

func _on_hp_changed(new_hp) -> void:
	hp_changed.emit(new_hp, false)

func _on_invulnerability_timer_timeout() -> void:
	stop_invulnerability()

func _on_stair_stun_timer_timeout() -> void:
	animation_player.speed_scale = 1
	whip_animation_player.speed_scale = 1
	if(health_component.remaining_hp > 0):
		invulnerability_timer.start()
		whip.monitorable = true
	else:
		fall_off_stairs()

func _on_subweapon_despawned() -> void:
	num_existing_subweapons -= 1

func _on_time_started() -> void:
	is_time_stopped = false
