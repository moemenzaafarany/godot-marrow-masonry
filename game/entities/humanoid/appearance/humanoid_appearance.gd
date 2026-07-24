extends Node3D

@export var skin_color: Color = Color("e0ac69")
@export var shirt_color: Color = Color("2b5c8f")
@export var pants_color: Color = Color("3a3a3a")

# Node References
@onready var head_mesh: MeshInstance3D = $Skeleton/Head
@onready var torso_mesh: MeshInstance3D = $Skeleton/Torso
@onready var left_shoulder: MeshInstance3D = $Skeleton/Torso/LeftShoulder
@onready var right_shoulder: MeshInstance3D = $Skeleton/Torso/RightShoulder

@onready var left_hand: Node3D = $Skeleton/LeftHand
@onready var left_hand_mesh: MeshInstance3D = $Skeleton/LeftHand/LeftHandMesh

@onready var right_hand: Node3D = $Skeleton/RightHand
@onready var right_hand_mesh: MeshInstance3D = $Skeleton/RightHand/RightHandMesh

@onready var left_foot: Node3D = $Skeleton/LeftFoot
@onready var left_foot_mesh: MeshInstance3D = $Skeleton/LeftFoot/LeftFootMesh

@onready var right_foot: Node3D = $Skeleton/RightFoot
@onready var right_foot_mesh: MeshInstance3D = $Skeleton/RightFoot/RightFootMesh

# Resting Home Positions
var default_l_hand_pos: Vector3
var default_r_hand_pos: Vector3
var default_l_foot_pos: Vector3
var default_r_foot_pos: Vector3

var walk_time: float = 0.0

func _ready() -> void:
	# Save resting local coordinates for interpolation
	default_l_hand_pos = left_hand.position
	default_r_hand_pos = right_hand.position
	default_l_foot_pos = left_foot.position
	default_r_foot_pos = right_foot.position
	
	apply_colors()

func apply_colors() -> void:
	_set_mesh_color(head_mesh, skin_color)
	_set_mesh_color(torso_mesh, shirt_color)
	_set_mesh_color(left_shoulder, shirt_color)   # Shoulders match the shirt
	_set_mesh_color(right_shoulder, shirt_color)  # Shoulders match the shirt
	_set_mesh_color(left_hand_mesh, skin_color)   # Bare hands
	_set_mesh_color(right_hand_mesh, skin_color)  # Bare hands
	_set_mesh_color(left_foot_mesh, pants_color)  # Shoes/feet match lower body
	_set_mesh_color(right_foot_mesh, pants_color)

func _set_mesh_color(mesh_instance: MeshInstance3D, color: Color) -> void:
	if mesh_instance:
		var mat = StandardMaterial3D.new()
		mat.albedo_color = color
		mat.roughness = 0.8
		mesh_instance.material_override = mat

## Procedural shoulder-and-floating-extremities walk animation
func animate_walking(delta: float, current_velocity: Vector3) -> void:
	var horizontal_speed = Vector3(current_velocity.x, 0, current_velocity.z).length()
	
	if horizontal_speed > 0.1:
		walk_time += delta * horizontal_speed * 4.5
		
		# Swing amplitude calculations
		var stride = sin(walk_time) * 0.28
		var lift_l = max(0.0, sin(walk_time)) * 0.16
		var lift_r = max(0.0, sin(walk_time + PI)) * 0.16
		
		# Slight shoulder dip/twist when walking for weight feel
		left_shoulder.rotation.z = sin(walk_time) * 0.08
		right_shoulder.rotation.z = -sin(walk_time) * 0.08
		
		# Floating Hands swing in opposite sync to feet
		left_hand.position = default_l_hand_pos + Vector3(0, lift_r * 0.4, -stride)
		right_hand.position = default_r_hand_pos + Vector3(0, lift_l * 0.4, stride)
		
		# Floating Feet step and lift off ground
		left_foot.position = default_l_foot_pos + Vector3(0, lift_l, stride)
		right_foot.position = default_r_foot_pos + Vector3(0, lift_r, -stride)
	else:
		# Idle resting state
		walk_time += delta * 2.0
		var float_bob = sin(walk_time) * 0.02
		
		# Reset shoulder rotations
		left_shoulder.rotation.z = move_toward(left_shoulder.rotation.z, 0.0, delta * 4.0)
		right_shoulder.rotation.z = move_toward(right_shoulder.rotation.z, 0.0, delta * 4.0)
		
		# Smoothly float hands/feet back to home positions
		left_hand.position = left_hand.position.lerp(default_l_hand_pos + Vector3(0, float_bob, 0), delta * 8.0)
		right_hand.position = right_hand.position.lerp(default_r_hand_pos + Vector3(0, -float_bob, 0), delta * 8.0)
		left_foot.position = left_foot.position.lerp(default_l_foot_pos, delta * 8.0)
		right_foot.position = right_foot.position.lerp(default_r_foot_pos, delta * 8.0)
