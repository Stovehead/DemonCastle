extends Sprite2D

func fade_in(length:float) -> void:
	material.set_shader_parameter("start_time", ShaderTime.time)
	material.set_shader_parameter("fade_length", length)
	material.set_shader_parameter("backwards", true)

func fade_out(length:float) -> void:
	material.set_shader_parameter("start_time", ShaderTime.time)
	material.set_shader_parameter("fade_length", length)
	material.set_shader_parameter("backwards", false)
