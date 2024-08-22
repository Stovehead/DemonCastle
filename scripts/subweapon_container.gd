extends TextureRect

@onready var icon:TextureRect = $TextureRect
@onready var icons:Array = [
	 null,
	preload("res://media/graphics/knife_icon.png"),
	preload("res://media/graphics/axe_icon.png"),
	preload("res://media/graphics/cross_icon.png"),
	preload("res://media/graphics/holy_water_icon.png"),
	preload("res://media/graphics/stopwatch_icon.png")
]

func _on_subweapon_changed(new_subweapon:int) -> void:
	if(new_subweapon < icons.size()):
		icon.texture = icons[new_subweapon]
