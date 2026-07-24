class_name CustomButton
extends TextureButton

@export var frame1: Texture2D
@export var frame2: Texture2D
@export var frame3: Texture2D
@export var frame4: Texture2D
@export var frame5: Texture2D

@export var animation_speed: float = 0.12

var frames: Array[Texture2D] = []
var current_frame_index: int = 0
var anim_tween: Tween

func _ready() -> void:
	frames = [frame1, frame2, frame3, frame4, frame5]
	
	if frame1:
		texture_normal = frame1
		# FIX: Force the button's minimum size to match the frame image dimensions
		custom_minimum_size = frame1.get_size()
		# Enable ignore_texture_size so it respects containers properly
		ignore_texture_size = true
		stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED

	# Recalculate center pivot point AFTER setting size
	pivot_offset = custom_minimum_size / 2.0

	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)

# --- FRAME ANIMATION LOGIC ---

func _on_button_down() -> void:
	_animate_to_frame(frames.size() - 1, animation_speed)

func _on_button_up() -> void:
	_animate_to_frame(0, animation_speed * 0.8)

func _animate_to_frame(target_index: int, duration: float) -> void:
	if anim_tween and anim_tween.is_running():
		anim_tween.kill()
		
	anim_tween = create_tween()
	anim_tween.tween_method(_set_frame_by_index, current_frame_index, target_index, duration)

func _set_frame_by_index(index: int) -> void:
	current_frame_index = index
	if index >= 0 and index < frames.size() and frames[index] != null:
		texture_normal = frames[index]
