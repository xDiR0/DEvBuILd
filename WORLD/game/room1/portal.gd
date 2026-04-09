extends Area3D

@export var next_room: String = "res://WORLD/game/room2/Room2.tscn"
@export var spawn_point: String = "start"

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.spawn_point_name = spawn_point
		call_deferred("_change_room")

func _change_room():
	get_tree().change_scene_to_file(next_room)
