extends Node

var sfx_paths:Array = [
	"res://media/sfx/whip.wav",
	"res://media/sfx/door.wav",
	"res://media/sfx/fall.wav",
	"res://media/sfx/death.wav",
	"res://media/sfx/invincible.wav",
	"res://media/sfx/pause.wav",
	"res://media/sfx/stopwatch.wav",
	"res://media/sfx/warp.wav",
	"res://media/sfx/time_running_out.wav",
	"res://media/sfx/hurt.wav",
	"res://media/sfx/select.wav",
	"res://media/sfx/water_enter.wav",
	"res://media/sfx/water_exit.wav",
	"res://media/sfx/whip_upgrade.wav",
	"res://media/sfx/heart.wav",
	"res://media/sfx/hit.wav",
	"res://media/sfx/money_bag.wav",
	"res://media/sfx/knife_throw.wav",
	"res://media/sfx/holy_water.wav",
	"res://media/sfx/block_break.wav",
	"res://media/sfx/1up.wav",
	"res://media/sfx/axe.wav",
	"res://media/sfx/cross.wav",
	"res://media/sfx/time_countdown.wav",
	"res://media/sfx/heart_countdown.wav",
	"res://media/sfx/secret.wav",
	"res://media/sfx/rosary.wav",
	"res://media/sfx/invincibility_running_out.wav",
	"res://media/sfx/heart_countdown.wav"]
var audio_streams:Array
var playing_sounds:Array
enum {
	WHIP,
	DOOR,
	FALL,
	DEATH,
	INVINCIBLE,
	PAUSE,
	STOPWATCH,
	WARP,
	TIME_RUNNING_OUT,
	HURT,
	SELECT,
	WATER_ENTER,
	WATER_EXIT,
	WHIP_UPGRADE,
	HEART,
	HIT,
	MONEY_BAG,
	KNIFE_THROW,
	HOLY_WATER,
	BLOCK_BREAK,
	ONE_UP,
	AXE,
	CROSS,
	TIME_COUNTDOWN,
	HEART_COUNTDOWN,
	SECRET,
	ROSARY,
	INVINCIBILITY_RUNNING_OUT
}

func play_sound_effect(effect_id:int) -> AudioStreamPlayer:
	var new_audio_player:AudioStreamPlayer = AudioStreamPlayer.new()
	new_audio_player.stream = audio_streams[effect_id]
	new_audio_player.finished.connect(_audio_finished.bind(new_audio_player))
	add_child(new_audio_player)
	new_audio_player.play()
	return new_audio_player

func play_sound_effect_no_overlap(effect_id:int) -> AudioStreamPlayer:
	if(is_instance_valid(playing_sounds[effect_id]) && playing_sounds[effect_id] is AudioStreamPlayer):
		stop_sound_effect(playing_sounds[effect_id])
	var new_audio_player = play_sound_effect(effect_id)
	playing_sounds[effect_id] = new_audio_player
	return new_audio_player

func stop_sound_effect(effect:AudioStreamPlayer):
	effect.stop()
	effect.queue_free()

func _audio_finished(audio_player:AudioStreamPlayer):
	audio_player.queue_free()

func _ready():
	for path in sfx_paths:
		var new_sfx:AudioStream = load(path)
		audio_streams.push_back(new_sfx)
	playing_sounds.resize(sfx_paths.size())
