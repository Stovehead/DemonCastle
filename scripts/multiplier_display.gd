extends TextureRect

const MAX_NUM_FLASHES:int = 16

@onready var doubler_icon:Texture = preload("res://media/graphics/doubler_icon.png")
@onready var tripler_icon:Texture = preload("res://media/graphics/tripler_icon.png")
@onready var flash_timer:Timer = $FlashTimer

var num_flashes = 0

func _on_max_subweapons_changed(new_max_subweapons:int) -> void:
	match(new_max_subweapons):
		2:
			flash_timer.start()
			num_flashes = 0
			texture = doubler_icon
		3:
			flash_timer.start()
			num_flashes = 0
			texture = tripler_icon
		_:
			flash_timer.stop()
			modulate.a = 0

func _on_flash_timer_timeout() -> void:
	if(modulate.a == 1):
		num_flashes += 1
	if(num_flashes == MAX_NUM_FLASHES):
		modulate.a = 1
	else:
		modulate.a = 1 - modulate.a
		flash_timer.start()
