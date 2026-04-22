extends Control

@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var save_and_exit_button: Button = $Panel/VBoxContainer/SaveAndExitButton
@onready var main_menu_button: Button = $Panel/VBoxContainer/MainMenuButton

func _ready():
	add_to_group("pause_menu")
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

	continue_button.pressed.connect(resume_game)
	settings_button.pressed.connect(open_settings)
	save_and_exit_button.pressed.connect(save_and_exit)
	main_menu_button.pressed.connect(return_to_main_menu)

func _unhandled_input(event):
	if visible and event.is_action_pressed("game_pause"):
		get_viewport().set_input_as_handled()
		resume_game()

func toggle_pause():
	if visible:
		resume_game()
	else:
		pause_game()

func pause_game():
	visible = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func resume_game():
	visible = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func open_settings():
	Global.capture_settings_return_state()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://menu/menu_settings/settings.tscn")

func save_and_exit():
	Global.save_game()
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func return_to_main_menu():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")
