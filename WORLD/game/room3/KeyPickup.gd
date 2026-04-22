extends Area3D

@export var victory_scene_path: String = "res://WORLD/game/ending/victory_screen.tscn"

var player_in_range = false

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _unhandled_input(event):
	if player_in_range and event.is_action_pressed("pickup_key"):
		get_viewport().set_input_as_handled()
		finish_game()

func _on_body_entered(body: Node):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node):
	if body.is_in_group("player"):
		player_in_range = false

func finish_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	Global.pending_player_data.clear()
	Global.settings_return_to_game = false
	Global.force_fresh_start = false
	get_tree().change_scene_to_file(victory_scene_path)
