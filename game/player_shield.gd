extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func appear() -> void:
	animation_player.play("appear")


func disappear() -> void:
	animation_player.play("disappear")
