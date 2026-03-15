extends Control

@onready var voice_manager = get_node("/root/VoiceManager")
@onready var progress_bar = $ProgressBar
@onready var status_label = $Label

func _ready():
	voice_manager.volume_changed.connect(_on_volume_changed)
	print("MicrophoneIndicator: Подключен к VoiceManager")

func _on_volume_changed(volume: float):
	progress_bar.value = volume * 100
	
	if volume > 0.7:
		status_label.text = "ГРОМКО!"
		status_label.modulate = Color.RED
	elif volume > 0.3:
		status_label.text = "Разговариваю"
		status_label.modulate = Color.YELLOW
	elif volume > 0.01:
		status_label.text = "Тихо"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Нет сигнала"
		status_label.modulate = Color.GRAY
