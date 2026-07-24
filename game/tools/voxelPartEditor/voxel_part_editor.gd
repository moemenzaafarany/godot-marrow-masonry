extends Node3D

# --- UI Node References ---
@export_group("UI References")
@export var slot_option_button: OptionButton
@export var file_name_input: LineEdit
@export var color_picker: ColorPickerButton
@export var erase_mode_button: Button
@export var save_button: Button

# --- Editor Parameters ---
@export_group("Editor Config")
@export var default_save_dir: String = "user://voxel_parts/"
@export var active_color: Color = Color.WHITE
@export var is_erase_mode: bool = false

# --- Camera Parameters ---
@export_group("Camera Config")
@export var rotation_sensitivity: float = 0.005
@export var pan_sensitivity: float = 0.01
@export var zoom_speed: float = 1.0
@export var min_zoom: float = 2.0
@export var max_zoom: float = 40.0

# --- 3D Scene References ---
@onready var camera: Camera3D = $CameraPivot/Camera3D
@onready var voxel_mesh_instance: MeshInstance3D = $VoxelMeshInstance

# --- Internal Data ---
var current_part_data: VoxelPartData

# Camera Navigation State
var is_orbiting: bool = false
var is_panning: bool = false

# Preset dimensions (width, height, depth) & base color per slot
const SLOT_PRESETS = {
	"Head": {"size": Vector3i(6, 6, 6), "color": Color("f2d2b1")},
	"Torso": {"size": Vector3i(8, 10, 4), "color": Color("3b5998")},
	"LeftArm": {"size": Vector3i(3, 8, 3), "color": Color("f2d2b1")},
	"RightArm": {"size": Vector3i(3, 8, 3), "color": Color("f2d2b1")},
	"LeftLeg": {"size": Vector3i(3, 9, 3), "color": Color("333333")},
	"RightLeg": {"size": Vector3i(3, 9, 3), "color": Color("333333")},
	"Hair": {"size": Vector3i(7, 3, 7), "color": Color("4a2e00")},
}

func _ready() -> void:
	current_part_data = VoxelPartData.new()
	_setup_mesh_instance()
	_populate_slot_options()
	_connect_ui_signals()
 
func _setup_mesh_instance() -> void:
	if not has_node("VoxelMeshInstance"):
		voxel_mesh_instance = MeshInstance3D.new()
		voxel_mesh_instance.name = "VoxelMeshInstance"
		add_child(voxel_mesh_instance)
	else:
		voxel_mesh_instance = get_node("VoxelMeshInstance")

func _populate_slot_options() -> void:
	if slot_option_button == null:
		return
	slot_option_button.clear()
	for slot_name in SLOT_PRESETS.keys():
		slot_option_button.add_item(slot_name)
	
	if slot_option_button.item_count > 0:
		_on_slot_selected(0)

func _connect_ui_signals() -> void:
	if slot_option_button:
		slot_option_button.item_selected.connect(_on_slot_selected)
	if color_picker:
		color_picker.color_changed.connect(_on_color_changed)
	if erase_mode_button:
		erase_mode_button.toggled.connect(_on_erase_mode_toggled)
	if save_button:
		save_button.pressed.connect(_on_save_pressed)

# --- Camera & Mouse Input Handling ---

func _unhandled_input(event: InputEvent) -> void:
	# Mouse Button Press / Release
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			# Shift + Right Click triggers Pan, regular Right Click triggers Orbit
			if Input.is_key_pressed(KEY_SHIFT):
				is_panning = event.pressed
				is_orbiting = false
			else:
				is_orbiting = event.pressed
				is_panning = false

		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed

		# Zooming
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(-zoom_speed)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(zoom_speed)

		# Left Click: Voxel Interaction
		elif event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_handle_voxel_click(event.position)

	# Camera Orbit / Pan Toggle
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			is_orbiting = event.pressed
		elif event.button_index == MOUSE_BUTTON_MIDDLE:
			is_panning = event.pressed
	elif event is InputEventMouseMotion:
		if is_orbiting:
			# Orbit around center origin
			camera.rotate_y(-event.relative.x * rotation_sensitivity)
			camera.rotate_object_local(Vector3.RIGHT, -event.relative.y * rotation_sensitivity)
		elif is_panning:
			# Pan camera relative to camera frame
			camera.translate(Vector3(-event.relative.x, event.relative.y, 0) * pan_sensitivity * 0.5)

func _zoom_camera(amount: float) -> void:
	var forward = -camera.transform.basis.z
	var new_pos = camera.position + forward * amount
	if new_pos.length() >= min_zoom and new_pos.length() <= max_zoom:
		camera.position = new_pos

# --- Precise Raycasting & Voxel Placement ---

func _handle_voxel_click(screen_pos: Vector2) -> void:
	var ray_origin = camera.project_ray_origin(screen_pos)
	var ray_dir = camera.project_ray_normal(screen_pos)

	var hit = _raycast_voxel_grid(ray_origin, ray_dir)
	
	if hit.has("grid_pos"):
		var grid_pos: Vector3i = hit.grid_pos
		var normal: Vector3i = hit.normal

		if is_erase_mode:
			current_part_data.remove_voxel(grid_pos)
		else:
			var target_pos = grid_pos + normal
			current_part_data.set_voxel(target_pos, active_color)
			
		rebake_mesh()
	else:
		# If no voxel was hit, check ray intersection with floor plane y=0
		if not is_erase_mode and ray_dir.y != 0:
			var t = -ray_origin.y / ray_dir.y
			if t > 0:
				var floor_hit = ray_origin + ray_dir * t
				var floor_grid_pos = Vector3i(floor_hit.floor())
				current_part_data.set_voxel(floor_grid_pos, active_color)
				rebake_mesh()

# Exact Ray-AABB Box Face Intersection Test
func _raycast_voxel_grid(ray_origin: Vector3, ray_dir: Vector3) -> Dictionary:
	var closest_t: float = INF
	var best_hit := {}

	for pos in current_part_data.voxels.keys():
		var box_min = Vector3(pos)
		var box_max = box_min + Vector3.ONE

		# Calculate entry/exit t parameters along each axis
		var t_min = (box_min - ray_origin) / ray_dir
		var t_max = (box_max - ray_origin) / ray_dir

		var t1 = Vector3(min(t_min.x, t_max.x), min(t_min.y, t_max.y), min(t_min.z, t_max.z))
		var t2 = Vector3(max(t_min.x, t_max.x), max(t_min.y, t_max.y), max(t_min.z, t_max.z))

		var t_near = max(max(t1.x, t1.y), t1.z)
		var t_far = min(min(t2.x, t2.y), t2.z)

		# Valid intersection test
		if t_near < t_far and t_near > 0.0 and t_near < closest_t:
			closest_t = t_near
			
			# Identify exact face normal based on entry axis
			var normal := Vector3i.ZERO
			if t_near == t1.x:
				normal.x = -1 if ray_dir.x > 0 else 1
			elif t_near == t1.y:
				normal.y = -1 if ray_dir.y > 0 else 1
			elif t_near == t1.z:
				normal.z = -1 if ray_dir.z > 0 else 1

			best_hit = {"grid_pos": pos, "normal": normal}

	return best_hit

# --- Preset & UI Handlers ---
func _on_slot_selected(index: int) -> void:
	var slot_name = slot_option_button.get_item_text(index)
	
	if file_name_input:
		file_name_input.text = slot_name.to_lower() + ".tres"
		
	_apply_slot_preset(slot_name)

func _apply_slot_preset(slot_name: String) -> void:
	if not SLOT_PRESETS.has(slot_name):
		return
		
	var preset = SLOT_PRESETS[slot_name]
	var size: Vector3i = preset["size"]
	var preset_color: Color = preset["color"]
	
	active_color = preset_color
	if color_picker:
		color_picker.color = preset_color
	
	current_part_data.voxels.clear()
	
	var offset_x = -size.x / 2
	var offset_y = 0
	var offset_z = -size.z / 2
	
	for x in range(size.x):
		for y in range(size.y):
			for z in range(size.z):
				var pos = Vector3i(x + offset_x, y + offset_y, z + offset_z)
				current_part_data.set_voxel(pos, active_color)
				
	rebake_mesh()

func _on_color_changed(new_color: Color) -> void:
	active_color = new_color

func _on_erase_mode_toggled(button_pressed: bool) -> void:
	is_erase_mode = button_pressed
func rebake_mesh() -> void:
	if voxel_mesh_instance and current_part_data:
		voxel_mesh_instance.mesh = VoxelBaker.bake_part(current_part_data)
# --- Saving / Exporting ---

func _on_save_pressed() -> void:
	var file_name: String = ""
	
	if file_name_input and not file_name_input.text.is_empty():
		file_name = file_name_input.text.strip_edges()
	elif slot_option_button and slot_option_button.selected != -1:
		file_name = slot_option_button.get_item_text(slot_option_button.selected).to_lower()
	else:
		file_name = "voxel_part"

	if not file_name.ends_with(".tres"):
		file_name += ".tres"

	if not DirAccess.dir_exists_absolute(default_save_dir):
		DirAccess.make_dir_recursive_absolute(default_save_dir)

	var full_path = default_save_dir + file_name
	var err = ResourceSaver.save(current_part_data, full_path)
	
	if err == OK:
		print("[VoxelEditor] Successfully saved voxel part to: ", full_path)
	else:
		push_error("[VoxelEditor] Failed to save voxel part: Error code " + str(err))
