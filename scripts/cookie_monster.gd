class_name CookieMonster
extends CharacterBody2D

func face_player() -> void:
	if(!is_instance_valid(Globals.current_player)):
		return
	var direction:int = -1 if Globals.current_player.global_position.x < global_position.x else 1
	scale.x = direction

func _ready() -> void:
	if(is_instance_valid(Globals.game_instance)):
		Globals.game_instance.enemy_hp_changed.emit(16, false)

func _physics_process(_delta: float) -> void:
	face_player()
