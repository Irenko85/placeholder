extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 10.0
@export var LERP_VALUE: float = 0.15

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

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	if direction:
		velocity.x = lerp(velocity.x, direction.x * speed, LERP_VALUE)
		velocity.z = lerp(velocity.z, direction.z * speed, LERP_VALUE)
		rig.rotation.y = lerp_angle(rig.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VALUE)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VALUE)
		velocity.z = lerp(velocity.z, 0.0, LERP_VALUE)
		
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
		
	was_on_floor = is_on_floor()
