extends CharacterBody3D
class_name FreeCam

# --- Movement Parameters ---
@export_group("Fly Movement")
@export var base_speed: float = 12.0
@export var fast_speed_multiplier: float = 2.5
@export var mouse_sensitivity: float = 0.003
@export var enable_collision: bool = false: set = _set_enable_collision

# --- Internal Camera References ---
@onready var camera: Camera3D = $Camera3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D

var pitch: float = 0.0
var yaw: float = 0.0
var is_looking: bool = false

func _ready() -> void:
	_update_collision()

func _set_enable_collision(value: bool) -> void:
	enable_collision = value
	_update_collision()

func _update_collision() -> void:
	if collision_shape:
		collision_shape.disabled = not enable_collision

func _unhandled_input(event: InputEvent) -> void:
	# Toggle Look Mode on Right Mouse Click
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_looking = event.pressed
			if is_looking:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			else:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

		# Speed adjustments via scroll wheel when looking
		elif is_looking:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				base_speed = clamp(base_speed + 1.0, 2.0, 50.0)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				base_speed = clamp(base_speed - 1.0, 2.0, 50.0)

	# Mouse Motion Look Around
	elif event is InputEventMouseMotion and is_looking:
		yaw -= event.relative.x * mouse_sensitivity
		pitch -= event.relative.y * mouse_sensitivity
		pitch = clamp(pitch, deg_to_rad(-89.0), deg_to_rad(89.0))
		
		rotation.y = yaw
		camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
	# Calculate input directions (WASD + Q/E or Shift/Space)
	var input_dir := Vector3.ZERO
	
	if Input.is_key_pressed(KEY_W): input_dir.z -= 1.0
	if Input.is_key_pressed(KEY_S): input_dir.z += 1.0
	if Input.is_key_pressed(KEY_A): input_dir.x -= 1.0
	if Input.is_key_pressed(KEY_D): input_dir.x += 1.0
	if Input.is_key_pressed(KEY_E) or Input.is_key_pressed(KEY_SPACE): input_dir.y += 1.0
	if Input.is_key_pressed(KEY_Q) or Input.is_key_pressed(KEY_SHIFT): input_dir.y -= 1.0

	input_dir = input_dir.normalized()

	# Align movement direction to camera orientaton
	var move_speed = base_speed
	if Input.is_key_pressed(KEY_ALT):
		move_speed *= fast_speed_multiplier

	var target_velocity = (transform.basis * input_dir) * move_speed

	if enable_collision:
		velocity = target_velocity
		move_and_slide()
	else:
		# Directly move position (Noclip flying)
		global_position += target_velocity * delta
