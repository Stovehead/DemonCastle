class_name StopComponent
extends Node

@export var freezable:bool = true
@export var can_be_multi_hit:bool = true
@export var timers:Array[Timer]
@export var animation_player:AnimationPlayer
@export var hitbox:Hitbox
@export var hurtbox:Hurtbox

@onready var stun_timer:Timer = $StunTimer
@onready var invulnerability_timer:Timer = $InvulnerabilityTimer

var is_stopped:bool = false
var is_frozen:bool = false
var is_stunned:bool = false
var will_unpause_animation_player:bool = false
var will_reenable_hitbox:bool = false
var timers_to_unpause:Array[Timer]
var animation_player_queue:Array[String]

func _ready() -> void:
	if(is_instance_valid(Globals.game_instance)):
		Globals.game_instance.time_stopped.connect(_on_time_stopped)
		Globals.game_instance.time_started.connect(_on_time_started)

func stop() -> void:
	is_stopped = true
	if(is_instance_valid(animation_player)):
		if(animation_player.is_playing()):
			will_unpause_animation_player = true
			for animation in animation_player.get_queue():
				animation_player_queue.push_back(animation)
			animation_player.pause()
	for timer in timers:
		if(!timer.paused):
			timers_to_unpause.push_back(timer)
			timer.paused = true

func start() -> void:
	is_stopped = false
	if(is_instance_valid(animation_player)):
		if(will_unpause_animation_player):
			will_unpause_animation_player = false
			animation_player.play()
			for animation in animation_player_queue:
				animation_player.queue(animation)
			animation_player_queue.clear()
	for timer in timers_to_unpause:
		timer.paused = false
	timers_to_unpause.clear()

func stun() -> void:
	is_stunned = true
	if(is_instance_valid(hitbox)):
		if(hitbox.monitoring):
			will_reenable_hitbox = true
			hitbox.set_deferred("monitoring", false)
	stun_timer.start()
	invulnerability_timer.start()
	if(is_frozen):
		return
	stop()

func _on_time_stopped() -> void:
	if(!freezable):
		return
	is_frozen = true
	if(is_stunned):
		return
	stop()

func _on_time_started() -> void:
	if(!is_frozen):
		return
	is_frozen = false
	if(is_stunned):
		return
	start()

func _on_stun_timer_timeout() -> void:
	is_stunned = false
	if(is_frozen):
		return
	start()

func _on_invulnerability_timer_timeout() -> void:
	if(will_reenable_hitbox && is_instance_valid(hitbox)):
		# Have to do this to force update collision for some reason
		hitbox.monitoring = true
		if(can_be_multi_hit):
			hitbox.monitoring = false		
			hitbox.monitoring = true
