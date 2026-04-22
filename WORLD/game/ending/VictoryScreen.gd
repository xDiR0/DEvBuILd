extends Control

var can_exit = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().create_timer(0.5).timeout
	can_exit = true

func _unhandled_input(event):
	if not can_exit:
		return

	if event is InputEventKey or event is InputEventMouseButton or event is InputEventJoypadButton:
		get_viewport().set_input_as_handled()
		get_tree().paused = false
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
