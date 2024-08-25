class_name Knife
extends Subweapon

@onready var sprite:Sprite2D = $Sprite2D

const SPEED:float = 4.5

func _on_area_entered(area:Area2D):
	super._on_area_entered(area)
	queue_free()

func _ready() -> void:
	sprite.flip_h = direction == -1
	SfxManager.play_sound_effect_no_overlap(SfxManager.KNIFE_THROW)

func _physics_process(delta: float) -> void:
	global_position.x += SPEED * direction
