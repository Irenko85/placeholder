extends Node3D

var direction: Vector3
const SPEED: float = 20.0
const ROTATION_SPEED: float = 5.0
const DAMAGE: float = 25.0

@export var projectile_particles: PackedScene


func _process(delta) -> void:
	global_position += delta * direction * SPEED
	rotation.x += delta * ROTATION_SPEED
	rotation.z += delta * ROTATION_SPEED / 2


func _on_timer_timeout() -> void:
	queue_free()


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		body.take_damage(DAMAGE)
	add_particles()
	queue_free()


func add_particles() -> void:
	var particles_instance = projectile_particles.instantiate() as GPUParticles3D
	particles_instance.global_position = global_position
	particles_instance.emitting = true
	add_sibling(particles_instance)
