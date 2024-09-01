class_name SecretItemSpawner
extends Node2D

var child:InstancePlaceholder

const ITEM_RISE_TIME:float = 1.0
const ITEM_DISPLACEMENT:Vector2 = Vector2(0, -16.0)

func _ready():
	if(get_child_count(false) > 0 && get_children(false)[0] is InstancePlaceholder):
		child = get_children(false)[0]

func spawn() -> void:
	SfxManager.play_sound_effect(SfxManager.SECRET)
	if(child != null):
		var new_instance:FallingObject = child.create_instance(true)
		new_instance.global_position = global_position
		var tween:Tween = get_tree().create_tween()
		tween.tween_property(new_instance, "global_position", global_position + ITEM_DISPLACEMENT,ITEM_RISE_TIME)
		await tween.finished
		if(is_instance_valid(new_instance)):
			new_instance.gravity_enabled = true
		set_script(null)
