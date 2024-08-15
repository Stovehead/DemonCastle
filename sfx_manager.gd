extends Node

var sfx_paths:Array = [
	"res://media/sfx/whip.wav",
	"res://media/sfx/door.wav",
	"res://media/sfx/fall.wav",
	"res://media/sfx/death.wav",
	"res://media/sfx/game_over.wav",
	"res://media/sfx/invincible.wav",
	"res://media/sfx/pause.wav",
	"res://media/sfx/stopwatch.wav",
	"res://media/sfx/warp.wav",
	"res://media/sfx/time_running_out.wav",
	"res://media/sfx/hurt.wav",
	"res://media/sfx/select.wav"]
var audio_streams:Array
enum {
	WHIP,
	DOOR,
	FALL,
	DEATH,
	GAME_OVER,
	INVINCIBLE,
	PAUSE,
	STOPWATCH,
	WARP,
	TIME_RUNNING_OUT,
	HURT,
	SELECT,
}

func play_sound_effect(effect_id:int):
	var new_audio_player:AudioStreamPlayer = AudioStreamPlayer.new()
	new_audio_player.stream = audio_streams[effect_id]
	new_audio_player.finished.connect(_audio_finished.bind(new_audio_player))
	add_child(new_audio_player)
	new_audio_player.play()

func _audio_finished(audio_player:AudioStreamPlayer):
	audio_player.queue_free()

func _ready():
	for path in sfx_paths:
		var new_sfx:AudioStream = load(path)
		audio_streams.push_back(new_sfx)
