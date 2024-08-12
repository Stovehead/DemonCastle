extends CharacterBody2D

const ACCELERATION:float = 1200
const MAX_SPEED:float = 60
const JUMP_SPEED:float = -180
const FAST_FALL_SPEED:float = 180

var player_direction:int = 1
var player_has_control:bool = false
var queued_jump:bool = false
var queued_whip:bool = false
var is_jumping:bool = false
var is_falling:bool = false
var is_whipping:bool = false
var is_damaged:bool = false
var is_crouching:bool = false
var on_stairs:bool = false
var in_stair_bottom:bool = false
var in_stair_top:bool = false
var current_stair:Stairs
var going_up_stairs:bool = false
var next_step:float
var current_step:int

@onready var collision:CollisionShape2D = $Collision
@onready var jump_timer:Timer = $JumpTimer
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite
@onready var whip:Area2D = $Whip
@onready var whip_animation_player:AnimationPlayer = $Whip/AnimationPlayer
@onready var stun_timer:Timer = $StunTimer


func horizontal_movement(input_direction:float, delta:float):
	velocity.x = abs(velocity.x)
	if(input_direction != 0 && !is_whipping && !is_crouching):
		velocity.x += ACCELERATION * delta
	else:
		velocity.x -= ACCELERATION * delta
	velocity.x = clamp(velocity.x, 0, MAX_SPEED)
	if(input_direction != 0 && !is_whipping):
		player_direction = input_direction
	velocity.x *= input_direction

func handle_input(delta:float) -> void:
	var did_horizontal_movement:bool = false
	# Attacking
	if(Input.is_action_just_pressed("attack")):
		if(!is_whipping):
			if(on_stairs):
				queued_whip = true
			else:
				if(is_crouching && is_on_floor()):
					animation_player.play("crouch_whip")
				else:
					animation_player.play("whip")
				whip_animation_player.play("level2")
				is_whipping = true

	# Movement on stairs
	if(on_stairs):
		if(!is_whipping):
			if(going_up_stairs):
				if(abs(position.x - next_step) < 0.2):
					going_up_stairs = false
					current_step += current_stair.direction * player_direction
				else:
					velocity = Vector2(30 * player_direction, 30 * player_direction * -current_stair.direction)
			# If stopped on stairs
			if(!going_up_stairs):
				# If reached top/bottom
				if(current_step <= 0 || current_step >= current_stair.height):
					on_stairs = false
					position.x = current_stair.position.x + Stairs.SINGLE_STAIR_HEIGHT * current_step * player_direction
					velocity.y = 100
					animation_player.play("idle")
				if(on_stairs):
					if(queued_whip):
						if(player_direction == current_stair.direction):
							animation_player.play("stair_up_whip")
						else:
							animation_player.play("stair_down_whip")
						whip_animation_player.play("level2")
						is_whipping = true
						queued_whip = false
						velocity = Vector2.ZERO
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
		# Stairs
		if(Input.is_action_pressed("up")):
			if(in_stair_bottom && !is_whipping):
				if(abs(current_stair.position.x - position.x) < 0.5):
					current_step = 0
					position.x = current_stair.position.x
					next_step = current_stair.position.x + Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
					on_stairs = true
					going_up_stairs = true
					player_direction = current_stair.direction
					animation_player.play("stair_up")
					did_horizontal_movement = true
				# Move towards stair
				else:
					horizontal_movement(sign(current_stair.position.x - position.x), delta)
					did_horizontal_movement = true
		elif(Input.is_action_pressed("down")):
			if(in_stair_top && !is_whipping):
				if(abs((current_stair.position.x + current_stair.height * Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction) - position.x) < 0.5):
					current_step = current_stair.height
					position.x = current_stair.position.x + current_stair.height * Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
					next_step = current_stair.position.x + (current_stair.height - 1) * Stairs.SINGLE_STAIR_HEIGHT * current_stair.direction
					on_stairs = true
					going_up_stairs = true
					player_direction = -current_stair.direction
					animation_player.play("stair_down")
					did_horizontal_movement = true
				# Move towards stair
				else:
					horizontal_movement(sign((current_stair.position.x + current_stair.height * Stairs.SINGLE_STAIR_HEIGHT) - position.x), delta)
					did_horizontal_movement = true
		
		# Crouching
		if(Input.is_action_just_pressed("down") && !in_stair_top):
			is_crouching = true
		if(Input.is_action_just_released("down")):
			is_crouching = false

		# Jump timer
		if(Input.is_action_just_pressed("jump")):
			queued_jump = true
			jump_timer.start()

		if(is_on_floor()):
			print(velocity.y)
			is_jumping = false
			is_falling = false
			# Horizontal movement
			if(!did_horizontal_movement):
				var input_direction:int = Input.get_axis("left", "right")
				horizontal_movement(input_direction, delta)
			
			# Jumping
			if(queued_jump && !is_whipping):
				queued_jump = false
				is_jumping = true
				jump_timer.stop()
				velocity.y = JUMP_SPEED
				animation_player.play("jump")
		else:
			if(!is_jumping):
				if(animation_player.assigned_animation == "walk"):
					animation_player.play("idle")
				if(!is_falling):
					is_falling = true
					velocity.y = FAST_FALL_SPEED
				velocity.x = 0

func handle_animation() -> void:
	if(animation_player.assigned_animation == "whip" || animation_player.assigned_animation == "crouch_whip"):
		if(!is_whipping):
			animation_player.play("idle")
	if(animation_player.assigned_animation == "jump"):
		if(is_on_floor()):
			animation_player.play("idle")
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
	if(player_direction == -1):
		sprite.flip_h = false
	else:
		sprite.flip_h = true
	whip.scale.x = -player_direction

func _ready():
	animation_player.play("idle")

func _physics_process(delta:float) -> void:
	handle_input(delta)
	if(on_stairs):
		collision.disabled = true
	else:
		collision.disabled = false
		velocity = $GravityComponent.apply_gravity(velocity, delta)
	move_and_slide()
	handle_animation()

func _on_jump_timer_timeout():
	queued_jump = false

func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "whip" || anim_name == "crouch_whip" || anim_name == "stair_up_whip" || anim_name == "stair_down_whip"):
		is_whipping = false

func _on_hitbox_area_entered(area):
	if(area.is_in_group("stairs")):
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
