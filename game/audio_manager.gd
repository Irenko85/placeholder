extends Node

@onready var toss_sound: AudioStreamPlayer3D = $TossSound


func play_toss_sound() -> void:
	toss_sound.pitch_scale = randf_range(0.5, 1.0)
	toss_sound.play()

