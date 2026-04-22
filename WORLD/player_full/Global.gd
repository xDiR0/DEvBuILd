extends Node

const DEFAULT_SCENE_PATH = "res://WORLD/game/room1/Room1.tscn"
const SAVE_PATH = "user://save_game.cfg"

var spawn_point_name = "start"
var pending_player_data = {}
var settings_return_to_game = false
var force_fresh_start = false
var settings_return_scene_path = ""
var settings_return_player_data = {}

func start_new_game():
	get_tree().paused = false
	pending_player_data.clear()
	spawn_point_name = "start"
	settings_return_to_game = false
	force_fresh_start = true
	settings_return_scene_path = ""
	settings_return_player_data.clear()
	clear_save()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	get_tree().change_scene_to_file(DEFAULT_SCENE_PATH)

func clear_save():
	if FileAccess.file_exists(SAVE_PATH):
		var user_dir = DirAccess.open("user://")
		if user_dir:
			user_dir.remove("save_game.cfg")

func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

func save_game(player: Node = null) -> bool:
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	var current_scene = get_tree().current_scene
	if current_scene == null:
		return false

	var config = ConfigFile.new()
	config.set_value("save", "scene_path", current_scene.scene_file_path)
	config.set_value("save", "spawn_point_name", spawn_point_name)

	if player:
		var player_3d = player as Node3D
		if player_3d:
			config.set_value("player", "position", player_3d.global_position)
			config.set_value("player", "rotation_y", player_3d.rotation.y)
		var health = player.get("current_health")
		if health != null:
			config.set_value("player", "current_health", health)

	return config.save(SAVE_PATH) == OK

func capture_settings_return_state(player: Node = null) -> bool:
	if player == null:
		player = get_tree().get_first_node_in_group("player")

	var current_scene = get_tree().current_scene
	if current_scene == null or player == null:
		return false

	var player_3d = player as Node3D
	if player_3d == null:
		return false

	settings_return_scene_path = current_scene.scene_file_path
	settings_return_player_data = {
		"position": player_3d.global_position,
		"rotation_y": player_3d.rotation.y,
		"current_health": player.get("current_health"),
		"camera_rotation_x": player.get("camera_rotation_x"),
		"camera_position": player.get_node("Camera3D").position if player.has_node("Camera3D") else Vector3(0, 1.6, 0),
		"camera_rotation": player.get_node("Camera3D").rotation if player.has_node("Camera3D") else Vector3.ZERO
	}
	settings_return_to_game = true
	force_fresh_start = false
	return true

func return_to_game_from_settings() -> bool:
	if settings_return_scene_path == "":
		return load_game()

	pending_player_data = settings_return_player_data.duplicate()
	settings_return_player_data.clear()
	var scene_path = settings_return_scene_path
	settings_return_scene_path = ""
	settings_return_to_game = false
	force_fresh_start = false
	get_tree().paused = false
	get_tree().change_scene_to_file(scene_path)
	return true

func load_game() -> bool:
	var config = ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false

	force_fresh_start = false
	pending_player_data = {
		"position": config.get_value("player", "position", Vector3.ZERO),
		"rotation_y": config.get_value("player", "rotation_y", 0.0),
		"current_health": config.get_value("player", "current_health", 100)
	}
	spawn_point_name = config.get_value("save", "spawn_point_name", "start")

	var scene_path = config.get_value("save", "scene_path", DEFAULT_SCENE_PATH)
	get_tree().change_scene_to_file(scene_path)
	return true

func consume_pending_player_data() -> Dictionary:
	var data = pending_player_data.duplicate()
	pending_player_data.clear()
	return data
