extends Control

@onready var single_player_button: CustomButton = $MarginContainer/VBoxContainer/SinglePlayerButton
@onready var multiplayer_button: CustomButton = $MarginContainer/VBoxContainer/MultiplayerButton
@onready var continue_button: CustomButton = $MarginContainer/VBoxContainer/ContinueButton
@onready var options_button: CustomButton = $MarginContainer/VBoxContainer/OptionsButton
@onready var exit_button: CustomButton = $MarginContainer/VBoxContainer/ExitButton

func _ready() -> void:
	# Connect click signals to respective functions
	single_player_button.pressed.connect(_on_single_player_pressed)
	multiplayer_button.pressed.connect(_on_multiplayer_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	options_button.pressed.connect(_on_options_pressed)
	exit_button.pressed.connect(_on_exit_pressed)

func _on_single_player_pressed() -> void:
	print("Starting Single Player mode...")
	# TODO: Load your offline single-player scene here

func _on_multiplayer_pressed() -> void:
	print("Opening Multiplayer menu / hosting network peer...")
	# TODO: Hook into NetworkManager.gd (Phase 1)

func _on_continue_pressed() -> void:
	print("Continuing previous game...")

func _on_options_pressed() -> void:
	print("Opening Options menu...")

func _on_exit_pressed() -> void:
	get_tree().quit()
