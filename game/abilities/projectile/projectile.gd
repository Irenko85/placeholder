extends Node3D

var direction: Vector3
const SPEED: float = 20.0
const ROTATION_SPEED: float = 5.0
const DAMAGE: float = 25.0


func _process(delta) -> void:
	global_position += delta * direction * SPEED
	rotation.x += delta * ROTATION_SPEED
	rotation.z += delta * ROTATION_SPEED / 2


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
	queue_free()
