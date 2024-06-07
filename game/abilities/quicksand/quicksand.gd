extends Node3D

const SLOWNESS: float = 0.25
const DEFAULT_SPEED: float = 5.0


func appear() -> void:
	position.y = -5
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", -0.9, 0.3).set_trans(Tween.TRANS_SINE)
	tween.tween_interval(7.0)
	tween.tween_callback(disappear)


func disappear() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", -2, 2)
	tween.tween_callback(queue_free)


func _on_area_3d_body_entered(body: Node3D) -> void:
	var player = body as Player
	player.speed *= SLOWNESS
	player.can_jump = false


func _on_area_3d_body_exited(body: Node3D) -> void:
	var player = body as Player
	player.speed = DEFAULT_SPEED
	player.can_jump = true

