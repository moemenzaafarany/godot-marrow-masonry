class_name CustomButton
extends TextureButton

<<<<<<< Updated upstream
@export var frame1: Texture2D
@export var frame2: Texture2D
@export var frame3: Texture2D
@export var frame4: Texture2D
@export var frame5: Texture2D

@export var animation_speed: float = 0.12 # Duration of frame transition (in seconds)

var frames: Array[Texture2D] = []
var current_frame_index: int = 0
var anim_tween: Tween

func _ready() -> void:
	# Store frames in an array for easy indexing
	frames = [frame1, frame2, frame3, frame4, frame5]
	
	# Set default starting texture
	if frame1:
		texture_normal = frame1

	# Center pivot point for smooth hover scaling
	pivot_offset = size / 2.0

	# Connect button signals
=======
# Exported variables show up directly in the Godot Inspector
@export var normal_texture: Texture2D
@export var pressed_texture: Texture2D

func _ready() -> void:
	# Assign textures
	if normal_texture:
		texture_normal = normal_texture
	if pressed_texture:
		texture_pressed = pressed_texture
		
	# Automatically calculate center pivot point for smooth scaling
	pivot_offset = size / 2.0
	
	# Connect built-in button signals for press state and hover animations
>>>>>>> Stashed changes
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

<<<<<<< Updated upstream
# --- FRAME ANIMATION LOGIC ---

# Play forward frames (1 -> 5) while holding down
func _on_button_down() -> void:
	_animate_to_frame(frames.size() - 1, animation_speed)

# Reverse frames (5 -> 1) when released
func _on_button_up() -> void:
	_animate_to_frame(0, animation_speed * 0.8)

# Interpolates frame index smoothly over time
func _animate_to_frame(target_index: int, duration: float) -> void:
	if anim_tween and anim_tween.is_running():
		anim_tween.kill() # Cancel any current playing animation
		
	anim_tween = create_tween()
	anim_tween.tween_method(_set_frame_by_index, current_frame_index, target_index, duration)

func _set_frame_by_index(index: int) -> void:
	current_frame_index = index
	if index >= 0 and index < frames.size() and frames[index] != null:
		texture_normal = frames[index]

# --- HOVER ANIMATION LOGIC ---

=======
# When holding mouse button down: switches to pressed image
func _on_button_down() -> void:
	if pressed_texture:
		texture_normal = pressed_texture

# When mouse released: swaps back to normal texture
func _on_button_up() -> void:
	if normal_texture:
		texture_normal = normal_texture

# Smooth scale-up on hover
>>>>>>> Stashed changes
func _on_mouse_entered() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.05, 1.05), 0.1).set_trans(Tween.TRANS_SINE)

<<<<<<< Updated upstream
=======
# Scale back to normal on exit
>>>>>>> Stashed changes
func _on_mouse_exited() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_trans(Tween.TRANS_SINE)
