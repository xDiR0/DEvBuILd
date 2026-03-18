extends Node3D

@onready var door_pivot = $DoorPivot
var is_open = false

func _ready():
	var vm = get_node_or_null("/root/VoiceManager")
	if vm:
		vm.voice_command_detected.connect(_on_command)

func _on_command(cmd: String):
	if cmd == "open" and not is_open:
		door_pivot.rotation_degrees.y = 90
		is_open = true
	elif cmd == "close" and is_open:
		door_pivot.rotation_degrees.y = 0
		is_open = false
