@tool
class_name HumanoidAppearance
extends VoxelAppearance

@export_category("Animation Settings")
@export var walk_anim_speed: float = 12.0
@export var walk_anim_amplitude: float = 0.15
@export var enable_ear_wiggle: bool = true

var walk_time: float = 0.0

# Initial local rest positions for floating limbs relative to Torso
const REST_POSITIONS = {
	"LeftHand": Vector3(-0.42, 0.15, -0.1),
	"RightHand": Vector3(0.42, 0.15, -0.1),
	"LeftFoot": Vector3(-0.16, -0.68, 0.0),
	"RightFoot": Vector3(0.16, -0.68, 0.0)
}

func _ready() -> void:
	super._ready() # Scans and registers all VoxelPartSlot children into `slots` dictionary

func _process(delta: float) -> void:
	if enable_ear_wiggle:
		_animate_sub_parts(delta)

## Sub-part micro animation (e.g., subtle ear wiggle)
func _animate_sub_parts(delta: float) -> void:
	var left_ear = get_slot("LeftEar")
	var right_ear = get_slot("RightEar")
	
	var wiggle = sin(Time.get_ticks_msec() * 0.005) * 0.1
	if left_ear:
		left_ear.rotation.z = wiggle
	if right_ear:
		right_ear.rotation.z = -wiggle

## Character walking animation
func animate_walk(delta: float, is_moving: bool) -> void:
	if not is_moving:
		walk_time = move_toward(walk_time, 0.0, delta * 5.0)
	else:
		walk_time += delta * walk_anim_speed

	var stride = sin(walk_time) * walk_anim_amplitude
	var bounce = abs(cos(walk_time)) * (walk_anim_amplitude * 0.5)

	# Whole head bobs (automatically moves Hair, Eyes, and Ears)
	var head_slot = get_slot("Head")
	if head_slot:
		head_slot.position.y = 0.5 + (bounce * 0.3)

	# Floating hands and feet swing relative to Torso
	_set_slot_pos("LeftHand", REST_POSITIONS["LeftHand"] + Vector3(0, bounce, stride))
	_set_slot_pos("RightHand", REST_POSITIONS["RightHand"] + Vector3(0, bounce, -stride))
	_set_slot_pos("LeftFoot", REST_POSITIONS["LeftFoot"] + Vector3(0, max(0.0, -stride), -stride))
	_set_slot_pos("RightFoot", REST_POSITIONS["RightFoot"] + Vector3(0, max(0.0, stride), stride))

func _set_slot_pos(slot_name: String, pos: Vector3) -> void:
	var slot = get_slot(slot_name)
	if slot:
		slot.position = pos
