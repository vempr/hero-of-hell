extends CharacterBody3D

enum FORM {
	DOG,
	DEVIL,
}

const DOG_SPEED: float = 40.0
const DOG_JUMP: float = 35.0
const DEVIL_SPEED: float = 25.0
const DEVIL_JUMP: float = 25.0

const SPRINT_MULTIPLIER: float = 2.0
const DOG_MAX_STAMINA: float = 10.0
const DEVIL_MAX_STAMINA: float = 5.0
const STAMINA_DRAIN: float = 1.0
const STAMINA_REGEN: float = 0.5

const ACCEL: float = 6.0
const DECEL: float = 8.0

var SPEED: float
var JUMP_VELOCITY: float
var target_speed: float
var target_jump: float
var current_form: FORM

var stamina: float
var max_stamina: float
var is_sprinting: bool = false
var sprint_factor: float = 1.0

@onready var camera: Camera3D = %Camera
@onready var cooldown_timer: Timer = %TransformCooldownTimer
@onready var animation: AnimationPlayer = %AnimationPlayer

var look_dir: Vector2
var camera_sens: float = 0.1


func _ready() -> void:
	current_form = FORM.DOG
	SPEED = DOG_SPEED
	JUMP_VELOCITY = DOG_JUMP
	target_speed = SPEED
	target_jump = JUMP_VELOCITY
	max_stamina = DOG_MAX_STAMINA
	stamina = max_stamina
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	%FrontChainsaw.visible = false
	%LeftChainsaw.visible = false
	%RightChainsaw.visible = false


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		elif Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		return
	
	var step: float = abs(DOG_SPEED - DEVIL_SPEED) * 5.0 * delta
	SPEED = move_toward(SPEED, target_speed, step)
	JUMP_VELOCITY = move_toward(JUMP_VELOCITY, target_jump, step)
	
	var sprint_input := Input.is_action_pressed("sprint")
	is_sprinting = sprint_input and stamina > 0.1 and _is_moving()
	if is_sprinting:
		stamina = max(stamina - STAMINA_DRAIN * delta, 0.0)
	else:
		stamina = min(stamina + STAMINA_REGEN * delta, max_stamina)
	
	var target_sprint := SPRINT_MULTIPLIER if is_sprinting else 1.0
	var rate := ACCEL if is_sprinting else DECEL
	sprint_factor = move_toward(sprint_factor, target_sprint, rate * delta)
	
	var current_speed := SPEED * sprint_factor
	
	if not is_on_floor():
		velocity += get_gravity() * 6.0 * delta
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)
	
	move_and_slide()
	_rotate_camera()


func _is_moving():
	return Input.get_vector("left", "right", "up", "down").length() > 0.1


func _input(event: InputEvent):
	if event is InputEventMouseMotion: look_dir = event.relative * 0.01
	elif event.is_action_pressed("transform") && cooldown_timer.is_stopped():
		cooldown_timer.start()
		
		match current_form:
			FORM.DOG:
				current_form = FORM.DEVIL
				target_speed = DEVIL_SPEED
				target_jump = DEVIL_JUMP
				max_stamina = DEVIL_MAX_STAMINA
				stamina = min(stamina, max_stamina)
				
				%FrontChainsaw.visible = true
				%LeftChainsaw.visible = true
				%RightChainsaw.visible = true
				animation.play("dog_out")
			FORM.DEVIL:
				current_form = FORM.DOG
				target_speed = DOG_SPEED
				target_jump = DOG_JUMP
				max_stamina = DOG_MAX_STAMINA
				
				animation.play("dog_in")


func _rotate_camera():
	rotate_y(-look_dir.x * camera_sens)
	camera.rotate_x(-look_dir.y * camera_sens)
	camera.rotation.x = clamp(camera.rotation.x, -PI / 6.0, PI / 2.0)
	look_dir = Vector2.ZERO
