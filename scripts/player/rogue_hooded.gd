extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var spring_arm_pivot = $SpringArmPivot
@export var sensitivity: float = 0.3

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED 

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("quit"):
		get_tree().quit()
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * sensitivity))
		spring_arm_pivot.rotate_x(deg_to_rad(-event.relative.y * sensitivity))
		spring_arm_pivot.rotation.x = clamp(spring_arm_pivot.rotation.x, -PI/3, PI/4)

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
