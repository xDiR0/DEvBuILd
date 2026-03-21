extends Control

@onready var progress_bar = $ProgressBar
@onready var status_label = $Label

var voice_manager: Node

func _ready():
	voice_manager = get_node_or_null("/root/VoiceManager")
	if voice_manager:
		voice_manager.voice_volume_changed.connect(_on_volume_changed)
		voice_manager.voice_command_detected.connect(_on_command_detected)
		status_label.text = "Готов"

func _on_volume_changed(volume: float):
	progress_bar.value = volume * 100

func _on_command_detected(command: String):
	status_label.text = "Открыть" if command == "open" else "Закрыть"
	await get_tree().create_timer(1.0).timeout
	status_label.text = "Готов"
