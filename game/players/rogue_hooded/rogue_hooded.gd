extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 10.0
@export var LERP_VALUE: float = 0.15
@export var acceleration: float = 4.0

var jumping: bool = false
var was_on_floor: bool = true

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var spring_arm_pivot: Node3D = $SpringArmPivot
@onready var spring_arm_3d: SpringArm3D = $SpringArmPivot/SpringArm3D
@onready var rig: Node3D = $Rig
@onready var animation_tree: AnimationTree = $AnimationTree

@export var sensitivity: float = 0.3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		spring_arm_3d.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		spring_arm_3d.rotation.x = clamp(spring_arm_3d.rotation.x, -PI/4, PI/4)

func _physics_process(delta: float) -> void:
	movement(delta)
	handle_animations()
	move_and_slide()

func movement(delta) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if is_multiplayer_authority():
		var vy = velocity.y
		velocity.y = 0
		var input = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
		var direction = Vector3(input.x, 0, input.y).rotated(Vector3.UP, spring_arm_pivot.rotation.y)
		rig.rotation.y = lerp_angle(rig.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VALUE)
		velocity = lerp(velocity, direction * speed, acceleration * delta)
		velocity.y = vy
		send_data.rpc(global_position, velocity, rig.rotation)
		
func handle_animations() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_velocity
		jumping = true
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

@rpc
func send_data(pos: Vector3, vel: Vector3, rotation):
	global_position = lerp(global_position, pos, 0.75)
	velocity = lerp(velocity, vel, 0.75)
	rig.rotation = lerp(rig.rotation, rotation, 0.75)
	
