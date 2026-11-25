extends Control

@export var next_scene_path: String = "res://scenes/level_01.tscn"

@onready var start_button: TextureButton = $VBoxContainer/StartButton
@onready var quit_button: TextureButton = $VBoxContainer/QuitButton

func _ready() -> void:
	start_button.grab_focus()

	for button in [start_button, quit_button]:
		button.pivot_offset = button.size / 2   # scales from the centre
		button.mouse_entered.connect(_pop_in.bind(button))
		button.mouse_exited.connect(_pop_out.bind(button))

func _pop_in(button: TextureButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2(1.08, 1.08), 0.12) \
		.set_trans(Tween.TRANS_BACK) \
		.set_ease(Tween.EASE_OUT)

func _pop_out(button: TextureButton) -> void:
	var tween := create_tween()
	tween.tween_property(button, "scale", Vector2.ONE, 0.12) \
		.set_trans(Tween.TRANS_QUAD) \
		.set_ease(Tween.EASE_OUT)

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(next_scene_path)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
