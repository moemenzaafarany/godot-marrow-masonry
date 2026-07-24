extends Control

@onready var ip_input: LineEdit = $VBoxContainer/IPInput
@onready var host_button: Button = $VBoxContainer/HostButton
@onready var join_button: Button = $VBoxContainer/JoinButton
@onready var status_label: Label = $VBoxContainer/StatusLabel

func _ready() -> void:
	host_button.pressed.connect(_on_host_pressed)
	join_button.pressed.connect(_on_join_pressed)
	
	NetworkManager.join_failed.connect(_on_join_failed)

func _on_host_pressed() -> void:
	status_label.text = "Starting server..."
	var err = NetworkManager.host_game()
	if err != OK:
		status_label.text = "Error hosting server."

func _on_join_pressed() -> void:
	status_label.text = "Connecting to server..."
	var err = NetworkManager.join_game(ip_input.text)
	if err != OK:
		status_label.text = "Error initiating connection."

func _on_join_failed() -> void:
	status_label.text = "Connection Failed!"
