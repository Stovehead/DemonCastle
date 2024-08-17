class_name SmallHeart
extends Upgrade

const FALL_SPEED:float = 30
const AMPLITUDE:float = 14
const FREQUENCY:float = 2

var time:float = 0
var offset:Vector2 = Vector2.ZERO
var hit_ground:bool = false
@onready var initial_position:Vector2 = global_position
@onready var ray_cast:RayCast2D = $RayCast2D
@onready var despawn_timer:Timer = $DespawnTimer

func _physics_process(delta: float) -> void:
	if(!hit_ground):
		offset.y = time * FALL_SPEED
		offset.x = sin(time * FREQUENCY) * AMPLITUDE
		global_position = initial_position + offset
		if(ray_cast.is_colliding()):
			despawn_timer.start()
			hit_ground = true
		time += delta

func do_upgrade(player:Player):
	player.num_hearts += 1
	player.hearts_changed.emit(player.num_hearts)
	SfxManager.play_sound_effect(SfxManager.HEART)
	queue_free()
