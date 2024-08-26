class_name Axe
extends Subweapon

@onready var sprite:Sprite2D = $Sprite2D
@onready var gravity_component:GravityComponent = $GravityComponent
var velocity:Vector2 = Vector2.ZERO

const INITIAL_VELOCITY:Vector2 = Vector2(110, -320)
const GRAVITY_SCALE:float = 1.5

func _on_area_entered(area:Area2D) -> void:
	super._on_area_entered(area)

func _ready() -> void:
	SfxManager.play_sound_effect_no_overlap(SfxManager.AXE)
	scale.x = direction
	velocity.x = INITIAL_VELOCITY.x * direction
	velocity.y = INITIAL_VELOCITY.y

func _physics_process(delta: float) -> void:
	velocity = gravity_component.apply_gravity_scaled(velocity, GRAVITY_SCALE, delta)
	global_position += velocity * delta

func _on_sfx_timer_timeout() -> void:
	SfxManager.play_sound_effect_no_overlap(SfxManager.AXE)
