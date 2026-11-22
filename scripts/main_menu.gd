extends Control

@export var next_scene_path: String = "res://scenes/level_01.tscn"

func _ready() -> void:
	$VBoxContainer/SartButton.grab_focus()

func _on_sart_button_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
