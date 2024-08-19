extends Sprite2D

@onready var shader = preload("res://shaders/fade.gdshader")
@onready var palette = preload("res://media/graphics/black_fade_palette.png")
@onready var image_2 = preload("res://media/graphics/test_screenshot_2.png")

func _ready() -> void:
	await get_tree().create_timer(2).timeout
	material.shader = shader
	material.set_shader_parameter("palette", palette)
	material.set_shader_parameter("start_time", ShaderTime.time)
	material.set_shader_parameter("fade_length", 0.3)
	await get_tree().create_timer(1).timeout
	texture = image_2
	material.set_shader_parameter("start_time", ShaderTime.time)
	material.set_shader_parameter("fade_length", 0.3)
	material.set_shader_parameter("backwards", true)
	await get_tree().create_timer(2).timeout
	material.set_shader_parameter("start_time", ShaderTime.time)
	material.set_shader_parameter("fade_length", 0.3)
	material.set_shader_parameter("backwards", false)
