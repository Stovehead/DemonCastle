extends Node

const ROLLOVER:float = 3600

var time:float = 0
var time_scale:float = 1

func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	RenderingServer.global_shader_parameter_set("ROLLOVER_TIME", ROLLOVER)

func _physics_process(delta: float) -> void:
	RenderingServer.global_shader_parameter_set("SCALABLE_TIME", time)
	time += delta * time_scale
	while(time > ROLLOVER):
		time -= ROLLOVER
