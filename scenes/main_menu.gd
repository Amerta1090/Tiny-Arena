extends Control

@onready var start_button: Button = %StartButton
@onready var continue_button: Button = %ContinueButton
@onready var quit_button: Button = %QuitButton

func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	continue_button.pressed.connect(_on_continue_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	continue_button.visible = GameState.has_save()
	continue_button.disabled = not GameState.has_save()

func _on_start_pressed() -> void:
	GameState.reset_game()
	GameState.save_game()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_continue_pressed() -> void:
	GameState.load_game()
	get_tree().change_scene_to_file("res://scenes/battle.tscn")

func _on_quit_pressed() -> void:
	GameState.save_game()
	get_tree().quit()
