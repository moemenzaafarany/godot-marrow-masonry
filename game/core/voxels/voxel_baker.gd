class_name VoxelBaker
extends RefCounted

const BLOCK_SIZE: float = 0.1 # Size of each individual voxel cube in meters

# Face directions & normal offsets
const DIRECTIONS = [
	Vector3i.UP, Vector3i.DOWN,
	Vector3i.LEFT, Vector3i.RIGHT,
	Vector3i.FORWARD, Vector3i.BACK
]

const FACES = {
	Vector3i.UP: [Vector3(0,1,1), Vector3(1,1,1), Vector3(1,1,0), Vector3(0,1,0)],
	Vector3i.DOWN: [Vector3(0,0,0), Vector3(1,0,0), Vector3(1,0,1), Vector3(0,0,1)],
	Vector3i.LEFT: [Vector3(0,0,0), Vector3(0,0,1), Vector3(0,1,1), Vector3(0,1,0)],
	Vector3i.RIGHT: [Vector3(1,0,1), Vector3(1,0,0), Vector3(1,1,0), Vector3(1,1,1)],
	Vector3i.FORWARD: [Vector3(0,0,0), Vector3(1,0,0), Vector3(1,1,0), Vector3(0,1,0)], # -Z
	Vector3i.BACK: [Vector3(1,0,1), Vector3(0,0,1), Vector3(0,1,1), Vector3(1,1,1)]      # +Z
}

static func bake_part(data: VoxelPartData) -> ArrayMesh:
	if data == null or data.voxels.is_empty():
		return null

	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)

	for pos in data.voxels.keys():
		var color: Color = data.voxels[pos]
		
		for dir in DIRECTIONS:
			var neighbor = pos + dir
			# Cull face if neighbor block exists
			if not data.voxels.has(neighbor):
				_add_face(st, pos, dir, color)

	st.generate_normals()
	return st.commit()

static func _add_face(st: SurfaceTool, pos: Vector3i, dir: Vector3i, color: Color) -> void:
	var quad = FACES[dir]
	var offset = Vector3(pos) * BLOCK_SIZE
	var normal = Vector3(dir)

	st.set_color(color)
	st.set_normal(normal)
	
	# Triangle 1
	st.add_vertex(offset + quad[0] * BLOCK_SIZE)
	st.add_vertex(offset + quad[1] * BLOCK_SIZE)
	st.add_vertex(offset + quad[2] * BLOCK_SIZE)

	# Triangle 2
	st.add_vertex(offset + quad[0] * BLOCK_SIZE)
	st.add_vertex(offset + quad[2] * BLOCK_SIZE)
	st.add_vertex(offset + quad[3] * BLOCK_SIZE)
