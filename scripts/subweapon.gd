class_name Subweapon
extends PlayerAttack

signal subweapon_despawned

var direction:int = 1

func _notification(what: int) -> void:
	if(what == NOTIFICATION_PREDELETE):
		subweapon_despawned.emit()
