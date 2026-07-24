@tool
class_name VoxelPartSlot
extends Node3D

## The voxel resource assigned to this slot (e.g., hair.tres, ear.tres)
@export var part_data: VoxelPartData:
	set(value):
		part_data = value
		rebake()

## Optional offset transform relative to parent
@export var slot_offset: Vector3 = Vector3.ZERO:
	set(value):
		slot_offset = value
		position = slot_offset

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D if has_node("MeshInstance3D") else _create_mesh_node()

func _ready() -> void:
	position = slot_offset
	rebake()

func _create_mesh_node() -> MeshInstance3D:
	var mi = MeshInstance3D.new()
	mi.name = "MeshInstance3D"
	add_child(mi)
	return mi

## Re-bakes the voxel geometry whenever part_data changes
func rebake() -> void:
	if not is_inside_tree():
		return
		
	if mesh_instance == null:
		mesh_instance = _create_mesh_node()

	if part_data != null:
		mesh_instance.mesh = VoxelBaker.bake_part(part_data)
	else:
		mesh_instance.mesh = null
