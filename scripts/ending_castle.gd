extends Sprite2D

const FRAMES_BETWEEN_SHAKES:int = 2

var frame_count:int = 0
@export var collapsing:bool = false

func _process(delta: float) -> void:
	if(!collapsing):
		return
	if(frame_count == 0):
		offset.x = 1
	elif(frame_count == FRAMES_BETWEEN_SHAKES - 1):
		offset.x = 0
	frame_count += 1
	if(frame_count == FRAMES_BETWEEN_SHAKES):
		frame_count = 0
