extends Node

@export var world_scene: PackedScene = preload("res://game/core/world/world.tscn")

@onready var ui_layer: CanvasLayer = $UILayer
@onready var main_menu_ui: Control = $UILayer/TempLobbyUI
@onready var world_container: Node3D = $WorldContainer

func _ready() -> void:
	# Listen for network state events to manage UI & World loading
	NetworkManager.server_created.connect(_load_world)
	NetworkManager.join_success.connect(_load_world)

func _load_world() -> void:
	# Hide the menu UI once connected
	main_menu_ui.hide()
	
	# Instantiate world if not already loaded
	if world_container.get_child_count() == 0:
		var world_inst = world_scene.instantiate()
		world_container.add_child(world_inst)
