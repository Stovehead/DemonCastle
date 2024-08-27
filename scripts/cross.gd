class_name Cross
extends Subweapon

const MAX_SPEED:float = 120.0
const TURNAROUND_TIME:float = 0.3
const TIME_UNTIL_TURNAROUND:float = 1.3
const MAX_NUM_SPINS:int = 6

var velocity:float = MAX_SPEED
var num_spins:int = 0

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite2D

func _ready() -> void:
	velocity = MAX_SPEED * direction
	scale.x = direction
	animation_player.speed_scale = 1.0

func _physics_process(delta: float) -> void:
	global_position.x += velocity * delta

func finished_spin() -> void:
	num_spins += 1
	if(num_spins == 6):
		print("finished spin")
		animation_player.get_animation(animation_player.current_animation).loop_mode = Animation.LOOP_NONE
		animation_player.queue("turnaround")
		animation_player.queue("reverse")
		get_tree().create_tween().tween_property(self, "velocity", -velocity, TURNAROUND_TIME)
