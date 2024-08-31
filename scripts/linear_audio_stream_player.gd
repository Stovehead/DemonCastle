class_name LinearAudioStreamPlayer
extends AudioStreamPlayer

var volume_linear:float:
	get:
		return db_to_linear(volume_db)
	set(new_volume):
		volume_db = linear_to_db(new_volume)
