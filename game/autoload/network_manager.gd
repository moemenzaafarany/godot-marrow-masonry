extends Node

# Default networking configuration
const DEFAULT_PORT: int = 7000
const MAX_PLAYERS: int = 8

# Signals for UI and World management
signal server_created
signal join_success
signal join_failed
signal player_connected(peer_id: int)
signal player_disconnected(peer_id: int)

var peer: ENetMultiplayerPeer

func _ready() -> void:
	# Connect Godot's built-in multiplayer signals
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)

func host_game(port: int = DEFAULT_PORT) -> Error:
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_server(port, MAX_PLAYERS)
	if error != OK:
		print("Failed to host server: ", error)
		return error
	
	multiplayer.multiplayer_peer = peer
	print("Server started on port ", port)
	server_created.emit()
	
	# Spawn the host player (Peer ID 1)
	_on_peer_connected(1)
	return OK

func join_game(address: String, port: int = DEFAULT_PORT) -> Error:
	if address.is_empty():
		address = "127.0.0.1" # Default to localhost
		
	peer = ENetMultiplayerPeer.new()
	var error = peer.create_client(address, port)
	if error != OK:
		print("Failed to create client: ", error)
		return error
		
	multiplayer.multiplayer_peer = peer
	print("Connecting to ", address, ":", port)
	return OK

# Signal Handlers
func _on_peer_connected(id: int) -> void:
	print("Player connected: ", id)
	player_connected.emit(id)

func _on_peer_disconnected(id: int) -> void:
	print("Player disconnected: ", id)
	player_disconnected.emit(id)

func _on_connected_to_server() -> void:
	print("Successfully connected to host!")
	join_success.emit()

func _on_connection_failed() -> void:
	print("Failed to connect to host.")
	join_failed.emit()
	multiplayer.multiplayer_peer = null
