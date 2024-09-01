extends Control

@export var left_display:TextureRect
@export var right_display:TextureRect
@export var up_display:TextureRect
@export var down_display:TextureRect
@export var start_display:TextureRect
@export var select_display:TextureRect
@export var a_display:TextureRect
@export var b_display:TextureRect

func _physics_process(_delta: float) -> void:
	if(is_instance_valid(left_display)):
		if(Input.is_action_pressed("left")):
			left_display.modulate = Color(1, 1, 1)
		else:
			left_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(right_display)):
		if(Input.is_action_pressed("right")):
			right_display.modulate = Color(1, 1, 1)
		else:
			right_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(up_display)):
		if(Input.is_action_pressed("up")):
			up_display.modulate = Color(1, 1, 1)
		else:
			up_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(down_display)):
		if(Input.is_action_pressed("down")):
			down_display.modulate = Color(1, 1, 1)
		else:
			down_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(start_display)):
		if(Input.is_action_pressed("start")):
			start_display.modulate = Color(1, 1, 1)
		else:
			start_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(select_display)):
		if(Input.is_action_pressed("debug")):
			select_display.modulate = Color(1, 1, 1)
		else:
			select_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(a_display)):
		if(Input.is_action_pressed("jump")):
			a_display.modulate = Color(1, 1, 1)
		else:
			a_display.modulate = Color(0.5, 0.5, 0.5)
	if(is_instance_valid(b_display)):
		if(Input.is_action_pressed("attack")):
			b_display.modulate = Color(1, 1, 1)
		else:
			b_display.modulate = Color(0.5, 0.5, 0.5)
