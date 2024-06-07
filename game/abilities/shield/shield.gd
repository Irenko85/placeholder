extends Node3D

@export var DURATION: float = 5.0

func appear() -> void:
	position.y = -5
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", 0, 0.4).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_interval(DURATION)
	tween.tween_callback(disappear)

func disappear() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position:y", -5, 1)
	tween.tween_callback(queue_free)

