extends GPUParticles3D


func _on_life_time_timer_timeout() -> void:
	queue_free()
