class_name Cross
extends Subweapon

const MAX_SPEED:float = 120.0
const TURNAROUND_TIME:float = 0.4
const MAX_NUM_SPINS:int = 6
const HALF_WIDTH:float = 8

var velocity:float = MAX_SPEED
var num_spins:int = 0
var turned_around:bool = false

@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var sprite:Sprite2D = $Sprite2D
@onready var player_detector:Area2D = $PlayerDetector
@onready var despawner:Node2D = $Despawner

func _ready() -> void:
	animation_player.play("default")
	velocity = MAX_SPEED * direction
	scale.x = direction
	animation_player.speed_scale = 1.0

func _physics_process(delta: float) -> void:
	global_position.x += velocity * delta
	check_if_reached_edge()

func check_if_reached_edge() -> void:
	if(is_instance_valid(Globals.game_instance.camera)):
		var camera:Camera2D = Globals.game_instance.camera
		var camera_center_position:Vector2 = camera.get_screen_center_position()
		var screen_half_width:float = get_viewport_rect().size.x/2
		if(global_position.x + HALF_WIDTH >= camera_center_position.x + screen_half_width || global_position.x - HALF_WIDTH <= camera_center_position.x - screen_half_width):
			turn_around(true)

func turn_around(hit_edge:bool) -> void:
	turned_around = true
	num_spins = 0
	despawner.process_mode = Node.PROCESS_MODE_INHERIT
	player_detector.monitoring = true
	if(!hit_edge):
		return
	direction *= -1
	velocity = MAX_SPEED * direction
	animation_player.play("reverse")

func finished_spin() -> void:
	num_spins += 1
	if(num_spins != MAX_NUM_SPINS):
		# Restart animation
		animation_player.stop(true)
		animation_player.play()
		return
	turn_around(false)
	animation_player.queue("turnaround")
	animation_player.queue("reverse")
	var tween = get_tree().create_tween()
	tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	tween.set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "velocity", -velocity, TURNAROUND_TIME)

func _on_player_detector_area_entered(area: Area2D) -> void:
	queue_free()
