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
	null,
	null,
	null,
	null,
]

signal hp_changed(new_hp:int)
signal hearts_changed(new_hearts:int)
signal whip_level_changed(new_level:int)
signal subweapon_changed(new_subweapon:int)
signal died

const ACCELERATION:float = 1200
const MAX_SPEED:float = 60
const JUMP_SPEED:float = -185
const FAST_FALL_SPEED:float = 280
const MIN_STUN_HEIGHT:float = 63
const MIN_BORDER_DISTANCE:float = 8
const KNOCKBACK_VELOCITY:Vector2 = Vector2(60, -130)
const DEFAULT_COLLISION_SIZE = Vector2(15, 30)
const SMALL_COLLISION_SIZE = Vector2(15, 23)

var player_direction:int = 1
var player_has_control:bool = true
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
var num_hearts:int = 0
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

var is_hurt:bool = false
var is_dead:bool = false
var time_up:bool = false

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

func get_weapon_to_attack() -> int:
	if(current_subweapon == Subweapons.NONE || num_existing_subweapons >= max_num_subweapons):
		return Subweapons.NONE
	return current_subweapon

func do_attack() -> void:
	if(on_stairs):
		if(player_direction == current_stair.direction):
			animation_player.play("stair_up_whip")
		else:
			animation_player.play("stair_down_whip")
		velocity = Vector2.ZERO
	else:
		if(is_crouching && is_on_floor()):
			animation_player.play("crouch_whip")
		else:
			animation_player.play("whip")
			if(collision.shape.get_rect().size.y < DEFAULT_COLLISION_SIZE.y):
				global_position.y -= (DEFAULT_COLLISION_SIZE.y - collision.shape.get_rect().size.y)/2
	var attack:int = get_weapon_to_attack()
	if(attack == Subweapons.NONE || attack == Subweapons.STOPWATCH || !Input.is_action_pressed("up") || num_hearts <= 0):
		whip.play_animation()
	else:
		num_hearts -= 1
		hearts_changed.emit(num_hearts)
		var subweapon_to_load:PackedScene = subweapon_scenes[attack]
		if(subweapon_to_load != null):
			new_subweapon = subweapon_to_load.instantiate()
			match(attack):
				Subweapons.KNIFE:
					if(new_subweapon is Knife):
						new_subweapon.direction = player_direction
		new_subweapon.subweapon_despawned.connect(_on_subweapon_despawned)
	is_whipping = true
	queued_whip = false

func activate_subweapon() -> void:
	if(new_subweapon != null):
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

func handle_input(delta:float) -> void:
	var did_horizontal_movement:bool = false
	var just_stair_transitioned:bool = false
	# Attacking
	if(player_has_control && !is_dead):
		if(Input.is_action_just_pressed("attack")):
			if(!is_whipping && !is_hurt):
				# Can't whip immediately on stairs
				if(on_stairs):
					queued_whip = true
				else:
					do_attack()

		# Movement on stairs
		if(on_stairs && stair_stun_timer.is_stopped()):
			last_grounded_y = global_position.y
			if(!is_whipping):
				# Moving
				if(going_up_stairs):
					# If reached a step
					if((global_position.x-next_step)*(global_position.x-next_step-get_position_delta().x) <= 0):
						if(just_warped):
							just_warped = false
						else:
							global_position.x = next_step
							going_up_stairs = false
							current_step += current_stair.direction * player_direction
					# Move the player to the next step
					else:
						velocity = Vector2(30 * player_direction, 30 * player_direction * -current_stair.direction)
				# If stopped on stairs
				if(!going_up_stairs):
					# If reached top/bottom
					if(current_step <= 0 || current_step >= current_stair.height):
						if(current_stair is TransitionalStairs && current_step == current_stair.height * current_stair.target):
							current_stair.transition(self)
							just_stair_transitioned = true
						else:
							on_stairs = false
							global_position.x = current_stair.global_position.x + Stairs.SINGLE_STAIR_HEIGHT * current_step * player_direction
							global_position.y -= 1
							velocity.y = 100
							animation_player.play("idle")
					# Making sure the player hasn't reached the top yet
					# You could probably put an else here, but I don't want to break it
					if(on_stairs && !just_stair_transitioned):
						# Do the whip that was queued earlier
						if(queued_whip):
							do_attack()
						else:
							var vertical_input_direction:int = Input.get_axis("down", "up")
							var horizontal_input_direction:int = Input.get_axis("left", "right") * current_stair.direction
							# If not holding a direction
							if(vertical_input_direction == 0 && horizontal_input_direction == 0):
								velocity = Vector2.ZERO
								if(player_direction == current_stair.direction):
									animation_player.play("stair_up_idle")
								else:
									animation_player.play("stair_down_idle")
							# Start moving up stairs
							else:
								if(vertical_input_direction == 1 || horizontal_input_direction == 1):
									going_up_stairs = true
									animation_player.play("stair_up")
									player_direction = current_stair.direction
									next_step = next_step + Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
								elif(vertical_input_direction == -1 || horizontal_input_direction == -1):
									going_up_stairs = true
									animation_player.play("stair_down")
									player_direction = -current_stair.direction
									next_step = next_step + Stairs.SINGLE_STAIR_HEIGHT * -current_stair.direction
		if(!on_stairs):
			# Getting on stairs
			if(Input.is_action_pressed("up")):
				if(in_stair_bottom && !is_whipping && !is_jumping && is_on_floor()):
					if((global_position.x-current_stair.global_position.x)*(global_position.x-current_stair.global_position.x-get_position_delta().x) <= 0):
						current_step = 0
						global_position.x = current_stair.global_position.x
						next_step = current_stair.global_position.x + Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
						on_stairs = true
						going_up_stairs = true
						player_direction = current_stair.direction
						animation_player.play("stair_up")
						did_horizontal_movement = true
						queued_jump = false
						jump_timer.stop()
					# Move towards stair
					else:
						horizontal_movement(sign(current_stair.global_position.x - global_position.x), 1, delta)
						did_horizontal_movement = true
			elif(Input.is_action_pressed("down")):
				if(in_stair_top && !is_whipping && !is_jumping && is_on_floor()):
					var top_stair_position:float = current_stair.global_position.x + current_stair.height * Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
					if((global_position.x-top_stair_position)*(global_position.x-top_stair_position-get_position_delta().x) <= 0):
						current_step = current_stair.height
						global_position.x = top_stair_position
						next_step = top_stair_position - Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
						on_stairs = true
						going_up_stairs = true
						player_direction = -current_stair.direction
						animation_player.play("stair_down")
						did_horizontal_movement = true
						queued_jump = false
						jump_timer.stop()
					# Move towards stair
					else:
						horizontal_movement(sign(top_stair_position - global_position.x), 1, delta)
						did_horizontal_movement = true
			
			# Crouching
			if(Input.is_action_just_pressed("down") && !in_stair_top):
				is_crouching = true
			if(Input.is_action_just_released("down") && stun_timer.is_stopped()):
				is_crouching = false

			# Jump timer
			if(Input.is_action_just_pressed("jump") && can_jump()):
				queued_jump = true
				jump_timer.start()

			if(is_on_floor()):
				is_jumping = false
				is_falling = false
				# Stunning
				if(global_position.y - last_grounded_y >= MIN_STUN_HEIGHT && !is_whipping):
					stun_timer.start()
					is_crouching = true
					SfxManager.play_sound_effect(SfxManager.FALL)
				if(time_up):
					player_direction *= -1
					die()
				elif(is_hurt && velocity.y >= 0 && !is_dead):
					if(health_component.remaining_hp > 0):
						player_direction = -player_direction
						is_hurt = false
						stun_timer.start()
						is_crouching = true
						invulnerability_timer.start()
					else:
						die()
				# Horizontal movement
				if(!did_horizontal_movement && !is_hurt && !is_dead):
					var input_direction:int = Input.get_axis("left", "right")
					if(is_crouching):
						horizontal_movement(0, 1, delta)
					else:
						horizontal_movement(input_direction, 1, delta)
				last_grounded_y = global_position.y
				# Jumping
				if(queued_jump && !is_whipping && !on_stairs):
					queued_jump = false
					is_jumping = true
					jump_timer.stop()
					velocity.y = JUMP_SPEED
					animation_player.play("jump")
			else:
				if(!is_jumping && !is_hurt):
					if(animation_player.assigned_animation == "walk"):
						animation_player.play("idle")
					if(!is_falling):
						is_falling = true
						velocity.y = FAST_FALL_SPEED
					velocity.x = 0
	elif(cutscene_control && !is_dead):
		horizontal_movement(cutscene_move_direction, cutscene_move_speed_factor, delta)
		is_crouching = false
		stun_timer.stop()
		if(is_hurt):
			is_hurt = false
	else:
		if(is_on_floor()):
			horizontal_movement(0, 1, delta) 
			is_crouching = false
			stun_timer.stop()

func die_with_animation(animation:String) -> void:
	died.emit()
	if(animation_player.current_animation == "idle"):
		player_direction *= -1
	animation_player.play(animation)
	is_dead = true
	hitbox.monitoring = false
	set_collision_layer_value(1, false)

func die() -> void:
	die_with_animation("death")

func death_barrier() -> void:
	died.emit()
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

func move_in_bounds():
	var limit_left:int = Globals.game_instance.camera.limit_left
	var limit_right:int = Globals.game_instance.camera.limit_right
	global_position.x = clamp(global_position.x, limit_left + MIN_BORDER_DISTANCE, limit_right - MIN_BORDER_DISTANCE)

func do_flashing():
	if(!invulnerability_timer.is_stopped()):
		modulate.a =  1 - modulate.a

func _ready():
	animation_player.play("idle")
	last_grounded_y = global_position.y

func _physics_process(delta:float) -> void:
	if(Input.is_action_just_pressed("debug")):
		current_subweapon += 1
		current_subweapon %= 6
		subweapon_changed.emit(current_subweapon)
	handle_input(delta)
	if(on_stairs):
		collision.disabled = true
	else:
		collision.disabled = false
		velocity = $GravityComponent.apply_gravity(velocity, delta)
	var old_velocity = velocity.x
	move_and_slide()
	velocity.x = old_velocity
	handle_animation()
	do_flashing()
	move_in_bounds()

func _on_jump_timer_timeout():
	queued_jump = false

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "whip" || anim_name == "crouch_whip" || anim_name == "stair_up_whip" || anim_name == "stair_down_whip"):
		is_whipping = false

func _on_hitbox_area_entered(area):
	if(area is Upgrade):
		area.do_upgrade(self)
	elif(area.is_in_group("stairs")):
		if(area.is_in_group("stairs_bottom")):
			in_stair_bottom = true
			current_stair = area.get_parent()
		elif(area.is_in_group("stairs_top")):
			in_stair_top = true
			current_stair = area.get_parent()

func _on_hitbox_area_exited(area):
	if(area.is_in_group("stairs")):
		if(area.is_in_group("stairs_bottom")):
			in_stair_bottom = false
		elif(area.is_in_group("stairs_top")):
			in_stair_top = false

func _on_stun_timer_timeout():
	if(!Input.is_action_pressed("down")):
		is_crouching = false

func _on_hitbox_got_hit(attacker:Hurtbox):
	SfxManager.play_sound_effect(SfxManager.HURT)
	hitbox.set_collision_mask_value(3, false)
	if(on_stairs):
		stair_stun_timer.start()
		animation_player.speed_scale = 0
		whip_animation_player.speed_scale = 0
		whip.set_deferred("monitorable", false)
		velocity = Vector2.ZERO
	else:
		if(global_position.x > attacker.global_position.x):
			player_direction = 1
		else:
			player_direction = -1
		velocity.x = KNOCKBACK_VELOCITY.x * player_direction
		velocity.y = KNOCKBACK_VELOCITY.y
		is_hurt = true
		is_whipping = false
		whip.reset()
		animation_player.play("hurt")

func _on_hp_changed(new_hp):
	hp_changed.emit(new_hp)

func _on_invulnerability_timer_timeout():
	modulate.a = 1
	hitbox.set_collision_mask_value(3, true)
	# Force update collisions
	hitbox.monitoring = false
	hitbox.monitoring = true

func _on_stair_stun_timer_timeout() -> void:
	animation_player.speed_scale = 1
	whip_animation_player.speed_scale = 1
	if(health_component.remaining_hp > 0):
		invulnerability_timer.start()
		is_whipping = false
		whip.monitorable = true
	else:
		on_stairs = false
		velocity = Vector2(0, FAST_FALL_SPEED)
		whip_animation_player.play("RESET")
		animation_player.play("idle")
		is_hurt = true

func _on_subweapon_despawned() -> void:
	num_existing_subweapons -= 1
