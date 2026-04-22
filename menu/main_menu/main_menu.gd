extends Control

@onready var button_continue: Button = $VBoxContainer/Button_continue

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	button_continue.disabled = not Global.has_save()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_start_pressed() -> void:
	Global.start_new_game()


func _on_button_continue_pressed() -> void:
	if not Global.load_game():
		Global.start_new_game()


func _on_button_options_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/menu_settings/settings.tscn")


func _on_button_exit_pressed() -> void:
	get_tree().quit()
