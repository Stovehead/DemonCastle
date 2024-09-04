class_name FakeHitbox
extends Area2D


func _on_area_entered(area: Area2D) -> void:
	if(area is not PlayerAttack):
		return
	SfxManager.play_sound_effect(SfxManager.FAKE_HIT)
