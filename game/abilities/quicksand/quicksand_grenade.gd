extends RigidBody3D

@export var quicksand: PackedScene
@onready var explosion_timer: Timer = $ExplosionTimer


func _on_body_entered(body: Node) -> void:
	if body is StaticBody3D:
		explosion_timer.start()


func _on_explosion_timer_timeout() -> void:
	spawn_quicksand()


func spawn_quicksand() -> void:
	var quicksand_instance = quicksand.instantiate()
	add_sibling(quicksand_instance)
	quicksand_instance.global_position.x = global_position.x
	quicksand_instance.global_position.z = global_position.z
	
	# TODO: Another way to do this?
	quicksand_instance.global_rotation.y += PI/2
	quicksand_instance.appear()
	queue_free()
