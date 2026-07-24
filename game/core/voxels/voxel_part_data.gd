class_name VoxelPartData
extends Resource

## Dictionary mapping Vector3i local positions to Color values
@export var voxels: Dictionary = {}

func set_voxel(pos: Vector3i, color: Color) -> void:
	voxels[pos] = color

func remove_voxel(pos: Vector3i) -> void:
	voxels.erase(pos)

func clear() -> void:
	voxels.clear()
