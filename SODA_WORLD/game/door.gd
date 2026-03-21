extends Node3D

@onready var door_pivot = $DoorPivot
var is_open = false
@onready var door_animations: AnimationPlayer = $DoorPivot/Door_animations
var animations = false


func _ready():
	var vm = get_node_or_null("/root/VoiceManager")
	if vm:
		vm.voice_command_detected.connect(_on_command)

func _on_command(cmd: String):
	if cmd == "open" and not is_open:
		is_open = true
		door_animations.play("open")
	elif cmd == "close" and is_open:
		is_open = false
		door_animations.play("close")
