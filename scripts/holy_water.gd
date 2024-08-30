class_name HolyWater
extends Subweapon

const DESPAWN_TIME:float = 1.28333
const BOTTLE_VELOCITY:Vector2 = Vector2(100, -100)

@onready var sprite:Sprite2D = $Sprite2D
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var bottle:Bottle = $Bottle
@onready var collision:CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	bottle.velocity.x = BOTTLE_VELOCITY.x * direction
	bottle.velocity.y = BOTTLE_VELOCITY.y
	collision.shape = RectangleShape2D.new()
	collision.shape.extents = Vector2(4, 4)

func _physics_process(_delta: float) -> void:
	if(is_instance_valid(bottle)):
		collision.global_position = bottle.global_position + Vector2(0, 4)

func _on_bottle_hit_ground(hit_position:Vector2) -> void:
	SfxManager.play_sound_effect_no_overlap(SfxManager.HOLY_WATER)
	global_position = hit_position
	sprite.visible = true
	animation_player.play("default")
	collision.position = Vector2.ZERO
	collision.shape.extents = Vector2(8, 8)
	await get_tree().create_timer(DESPAWN_TIME, false, true).timeout
	queue_free()
