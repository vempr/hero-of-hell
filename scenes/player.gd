extends CharacterBody3D


const SPEED: float = 25.0
const JUMP_VELOCITY: float = 25.0

@onready var camera: Camera3D = %Camera

var look_dir: Vector2
var camera_sens: float = 0.1


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	if not is_on_floor():
		velocity += get_gravity() * 6.0 * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	_rotate_camera()


func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01

func _rotate_camera():
	rotate_y(-look_dir.x * camera_sens)
	camera.rotate_x(-look_dir.y * camera_sens)
	camera.rotation.x = clamp(camera.rotation.x, -PI / 2.0, PI / 2.0)
	look_dir = Vector2.ZERO
