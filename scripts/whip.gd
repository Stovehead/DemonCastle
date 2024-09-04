class_name Whip
extends PlayerAttack

@onready var sprite:Sprite2D = $Sprite
@onready var animation_player:AnimationPlayer = $AnimationPlayer
@onready var collision:CollisionShape2D = $Collision

@export var played_sound:bool = false
var current_sfx:AudioStreamPlayer

var current_level:int = 1:
	set(new_current_level):
		current_level = new_current_level
		sprite.use_parent_material = current_level >= 3
		if(animation_player.is_playing()):
			var current_position:float = animation_player.current_animation_position
			play_animation()
			animation_player.advance(current_position)
		if(new_current_level == 1):
			damage = 1
		else:
			damage = 2

@export var new_position:Vector2:
	set(new_new_position):
		new_position = new_new_position
		position.x = new_position.x * scale.x
		position.y = new_position.y

func play_animation() -> void:
	animation_player.stop()
	if(current_level == 1):
		animation_player.play("level1")
	elif(current_level == 2):
		animation_player.play("level2")
	else:
		animation_player.play("level3")

func play_sound() -> void:
	if(!played_sound && visible):
		current_sfx = SfxManager.play_sound_effect(SfxManager.WHIP)
		played_sound = true

func reset() -> void:
	animation_player.play.call_deferred("RESET")
	if(is_instance_valid(current_sfx)):
		SfxManager.stop_sound_effect(current_sfx)

func _on_area_entered(area: Area2D) -> void:
	super._on_area_entered(area)
	if(area is not Hitbox && area is not FakeHitbox):
		return
	if(is_instance_valid(current_sfx)):
		SfxManager.stop_sound_effect(current_sfx)
