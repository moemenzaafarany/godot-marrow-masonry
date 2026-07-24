extends CharacterBody3D

@export var speed: float = 5.0
@export var rotation_speed: float = 3.0 # Speed of turning in radians per second
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
	# 1. Handle physics movement & rotation for the authority (controlling player)
	if is_multiplayer_authority():
		if not is_on_floor():
			velocity.y -= gravity * delta

		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = jump_velocity

		# Get raw inputs
		var rotation_input := Input.get_axis("ui_right", "ui_left") # Left rotates positive Y, Right rotates negative Y
		var forward_input := Input.get_axis("ui_up", "ui_down")     # Up moves towards -Z (forward), Down moves towards +Z (back)

		# Apply Y-axis rotation (Turning left/right)
		rotate_y(rotation_input * rotation_speed * delta)

		# Move along local forward vector (-transform.basis.z)
		var forward_dir := -transform.basis.z
		
		if forward_input != 0.0:
			# forward_input: -1 for ui_up (moves forward), +1 for ui_down (moves backward)
			var target_vel = forward_dir * (-forward_input * speed)
			velocity.x = target_vel.x
			velocity.z = target_vel.z
		else:
			velocity.x = move_toward(velocity.x, 0, speed)
			velocity.z = move_toward(velocity.z, 0, speed)

		move_and_slide()

	# 2. Trigger procedural limb animation on ALL clients (local & remote)
	if appearance and appearance.has_method("animate_walking"):
		appearance.animate_walking(delta, velocity)
