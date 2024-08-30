extends Hurtbox

var expired:bool = false

func _physics_process(_delta: float) -> void:
	if(expired):
		queue_free()
		return
	expired = true
