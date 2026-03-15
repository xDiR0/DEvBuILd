extends Node

signal volume_changed(volume)

var mic_player: AudioStreamPlayer
var current_volume: float = 0.0
var mic_bus_index: int

func _ready():
	# Получаем индекс шины MicBus
	mic_bus_index = AudioServer.get_bus_index("MicBus")
	# Создаем плеер для микрофона
	mic_player = AudioStreamPlayer.new()
	mic_player.stream = AudioStreamMicrophone.new()
	mic_player.bus = "MicBus"  # Направляем звук микрофона на MicBus
	add_child(mic_player)
	
	# Запускаем микрофон
	mic_player.play()
	print("✅ Микрофон запущен на шине: ", mic_player.bus)
	mic_player.volume_db = -80
	# Таймер для проверки громкости
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.timeout.connect(_check_volume)
	add_child(timer)
	timer.start()
	print("✅ Таймер запущен")

func _check_volume():
	var db = AudioServer.get_bus_peak_volume_left_db(mic_bus_index, 0)
	var linear = db_to_linear(db)
	current_volume = clamp(linear * 50.0, 0.0, 1.0)
	emit_signal("volume_changed", current_volume)
