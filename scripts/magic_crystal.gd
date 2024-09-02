extends Upgrade

@export var sprite:Sprite2D
@export var falling_object:FallingObject
@export var animation_player:AnimationPlayer

@onready var stage_clear_music:AudioStream = preload("res://media/music/stage_clear.ogg")
@onready var all_clear_music:AudioStream = preload("res://media/music/all_clear.ogg")

var flashing:bool = true

func _process(_delta: float) -> void:
	if(flashing):
		sprite.visible = !sprite.visible

func _on_start_fall_timer_timeout() -> void:
	falling_object.gravity_enabled = true
	monitorable = true
	flashing = false
	sprite.visible = true
	animation_player.play("default")

func do_upgrade(player:Player):
	player.can_move_horizontally = false
	player.health_component.remaining_hp = 16
	player.hp_changed.emit(player.health_component.remaining_hp, false)
	if(Globals.game_instance.current_stage.stage_number == Game.FINAL_STAGE_NUMBER):
		Globals.game_instance.music_player.stream = all_clear_music
	else:
		Globals.game_instance.music_player.stream = stage_clear_music
	Globals.game_instance.music_player.play()
	Globals.game_instance.begin_stage_clear()
	get_parent().queue_free()
