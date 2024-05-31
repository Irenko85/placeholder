extends CharacterBody3D
class_name Player

@export var speed: float = 5.0
@export var jump_velocity: float = 10.0
@export var LERP_VALUE: float = 0.15
@export var acceleration: float = 4.0
@export var sensitivity: float = 0.3
@export var player_health: float = 100.0

@export_category("Abilities")
@export var player_shield: PackedScene
@export var projectile: PackedScene

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var jumping: bool = false
var can_move: bool = true
var was_on_floor: bool = true
var can_jump: bool = true

@onready var spring_arm_pivot: Node3D = $Rig/SpringArmPivot
@onready var spring_arm_3d: SpringArm3D = $Rig/SpringArmPivot/SpringArm3D
@onready var rig: Node3D = $Rig
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var camera_3d: Camera3D = $Rig/SpringArmPivot/SpringArm3D/Camera3D
@onready var dash_timer = $DashTimer
@onready var shield_spawner: Node3D = %ShieldSpawner
@onready var projectile_spawner = %ProjectileSpawner


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 


func _manage_camera(event: InputEvent) -> void:
	if is_multiplayer_authority() and event is InputEventMouseMotion:
		rig.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		spring_arm_3d.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/4, PI/4)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	_manage_camera(event)


func _physics_process(delta: float) -> void:
	apply_gravity(delta)
	handle_animations()
	
	if can_move:
		movement(delta)
	else:
		velocity.x = lerp(velocity.x, 0.0, acceleration * delta)
		velocity.z = lerp(velocity.z, 0.0, acceleration * delta)
	
	if Input.is_action_just_pressed("throw"):
		throw_projectile.rpc()
	
	# Can't block on air
	if Input.is_action_just_pressed("block") and is_on_floor() and is_multiplayer_authority():
		block.rpc()
		
	if is_multiplayer_authority():
		send_data.rpc(global_position, velocity, rig.rotation)
	move_and_slide()


func apply_gravity(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta


@rpc("call_local")
func block() -> void:
	animation_tree.get("parameters/playback").travel("Block")
	
	var shield_instance = player_shield.instantiate()
	add_sibling(shield_instance)
	shield_instance.global_position = shield_spawner.global_position
	shield_instance.global_rotation = shield_spawner.global_rotation
	shield_instance.appear()


@rpc("call_local")
func throw_projectile() -> void:
	# change the animation to throw
	animation_tree.get("parameters/playback").travel("Throw")
	
	var projectile_instance = projectile.instantiate()
	add_sibling(projectile_instance)
	projectile_instance.global_position = projectile_spawner.global_position
	projectile_instance.global_rotation = projectile_spawner.global_rotation
	projectile_instance.direction = -camera_3d.get_global_transform().basis.z


func movement(delta) -> void:
	if is_multiplayer_authority():
		var vy = velocity.y
		velocity.y = 0
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
		var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, rig.rotation.y)
		velocity = lerp(velocity, direction * speed, acceleration * delta)
		velocity.y = vy
		if Input.is_action_just_pressed("jump") and is_on_floor() and can_jump:
			jump()
		if Input.is_action_just_pressed("dash"):
			dash(direction)


func jump() -> void:
	velocity.y = jump_velocity
	jumping = true


func dash(direction) -> void:
	Debug.sprint(dash_timer.time_left)
	if dash_timer.time_left > 0:
		return
	velocity = direction * speed * 5
	dash_timer.start()


func handle_animations() -> void:
	if jumping:
		animation_tree.set("parameters/conditions/jumping", true)
		animation_tree.set("parameters/conditions/grounded", false)
	if is_on_floor() and not was_on_floor:
		jumping = false
		animation_tree.set("parameters/conditions/jumping", false)
		animation_tree.set("parameters/conditions/grounded", true)
		
	if not is_on_floor() and not jumping:
		animation_tree.get("parameters/playback").travel("Jump_Idle")
		animation_tree.set("parameters/conditions/grounded", false)
		
	var vl = velocity * rig.transform.basis
	animation_tree.set("parameters/Movement/blend_position", Vector2(vl.x, -vl.z) / speed)
		
	was_on_floor = is_on_floor()


func setup(player_data: Statics.PlayerData) -> void:
	name = str(player_data.id)
	set_multiplayer_authority(player_data.id)
	camera_3d.current = is_multiplayer_authority()


@rpc
func send_data(pos: Vector3, vel: Vector3, rotation):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	rig.rotation = lerp(rig.rotation, rotation, 0.75)


func take_damage(amount: float) -> void:
	player_health -= amount
	if player_health <= 0:
		player_health = 0
		die()


func die() -> void:
	animation_tree.get("parameters/playback").travel("Death")
	can_move = false
