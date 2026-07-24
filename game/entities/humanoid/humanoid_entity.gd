extends CharacterBody3D

@export var speed: float = 5.0
@export var jump_velocity: float = 4.5

# Gravity from project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var appearance: Node3D = $AppearanceContainer/HumanoidAppearance
@onready var camera: Camera3D = $CameraPivot/Camera3D
func _enter_tree() -> void:
	# In world.gd, the node name was set to the player's network Peer ID (e.g. "1", "123456").
	# We set the multiplayer authority of this node to match that Peer ID.
	set_multiplayer_authority(str(name).to_int())

func _ready() -> void:
	# Only activate the camera if this instance is controlled by the local player
	if is_multiplayer_authority():
		camera.make_current()
	else:
		camera.clear_current()

func _physics_process(delta: float) -> void:
	# 1. Handle physics movement for the authority (controlling player)
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		move_and_slide()

	# 2. Trigger procedural limb animation on ALL clients (local & remote)
	if appearance and appearance.has_method("animate_walking"):
		appearance.animate_walking(delta, velocity)
