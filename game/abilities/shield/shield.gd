extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func appear() -> void:
	animation_player.play("appear")


func disappear() -> void:
	await get_tree().create_timer(10.0).timeout
	queue_free()
