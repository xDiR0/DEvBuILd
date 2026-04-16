extends Node

signal voice_command_detected(command)
signal voice_volume_changed(volume)

var mic_bus_index: int = -1
var mic_player: AudioStreamPlayer
var is_speaking: bool = false
var silence_timer: float = 0.0

# Клавиша F для команды open
@export var open_key: Key = KEY_F

func _ready():
	_setup_microphone()
	add_to_group("voice_manager")
	set_process_input(true)

func _setup_microphone():
	mic_bus_index = AudioServer.get_bus_index("MicBus")
	
	if mic_bus_index == -1:
		print("ОШИБКА: Шина 'MicBus' не найдена!")
		print("Доступные шины:")
		for i in AudioServer.bus_count:
			print("  - ", AudioServer.get_bus_name(i))
		return
	
	mic_player = AudioStreamPlayer.new()
	mic_player.stream = AudioStreamMicrophone.new()
	mic_player.bus = "MicBus"
	add_child(mic_player)
	mic_player.play()
	
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_check_volume)
	add_child(timer)
	timer.start()
	
	print("✅ Микрофон настроен")

func _input(event: InputEvent):
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == open_key:
			print("⌨️ Клавиша F нажата → open")
			_send_open_command()

func _check_volume():
	if mic_bus_index == -1:
		return
	
	if mic_bus_index < 0 or mic_bus_index >= AudioServer.bus_count:
		mic_bus_index = -1
		return
	
	var db = AudioServer.get_bus_peak_volume_left_db(mic_bus_index, 0)
	var volume = db_to_linear(db)
	emit_signal("voice_volume_changed", min(volume, 1.0))
	
	if volume > 0.02 and not is_speaking:
		is_speaking = true
		print("🎤 Слушаю...")
	elif volume < 0.01 and is_speaking:
		silence_timer += 0.1
		if silence_timer >= 0.5:
			is_speaking = false
			silence_timer = 0.0
			_send_open_command()
	elif is_speaking:
		silence_timer = 0.0

func _send_open_command():
	print("📢 Команда: open")
	emit_signal("voice_command_detected", "open")
