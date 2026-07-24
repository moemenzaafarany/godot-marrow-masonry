extends Node3D

@export var player_scene: PackedScene = preload("res://game/entities/humanoid/humanoid_entity.tscn")
@onready var players_container: Node3D = $Players

func _ready() -> void:
	# Only the Server / Host handles spawning player nodes
	if multiplayer.is_server():
		NetworkManager.player_connected.connect(_spawn_player)
		NetworkManager.player_disconnected.connect(_despawn_player)
		
		# If host is already connected, spawn host avatar
		for id in multiplayer.get_peers():
			_spawn_player(id)

func _spawn_player(peer_id: int) -> void:
	if not players_container.has_node(str(peer_id)):
		var new_player = player_scene.instantiate()
		new_player.name = str(peer_id) # Set node name to Peer ID for network ownership
		players_container.add_child(new_player)
		print("Spawned player entity for peer: ", peer_id)

func _despawn_player(peer_id: int) -> void:
	if players_container.has_node(str(peer_id)):
		players_container.get_node(str(peer_id)).queue_free()
		print("Removed player entity for peer: ", peer_id)
