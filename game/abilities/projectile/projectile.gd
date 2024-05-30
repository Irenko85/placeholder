extends Node3D

var direction: Vector3
const SPEED: float = 20.0
const ROTATION_SPEED: float = 5.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	global_position += delta * direction * SPEED
	rotation.x += delta * ROTATION_SPEED
	rotation.z += delta * ROTATION_SPEED / 2


func _on_timer_timeout():
	queue_free()
