extends Node

var vosk = null
var is_initialized = false

func _ready():
	# Проверяем доступность класса
	if ClassDB.class_exists("VoskVoiceRecognition"):
		print("VOSK найден")
		vosk = ClassDB.instantiate("VoskVoiceRecognition")
		add_child(vosk)
	else:
		print("VOSK не найден!")

func initialize(model_path: String) -> bool:
	if vosk and vosk.has_method("initialize"):
		var result = vosk.initialize(model_path)
		is_initialized = result
		return result
	return false

func get_devices():
	if vosk and vosk.has_method("get_input_devices"):
		return vosk.get_input_devices()
	return []

func set_device(device_index: int):
	if vosk and vosk.has_method("set_input_device"):
		vosk.set_input_device(device_index)

func start():
	if vosk and vosk.has_method("start_listening"):
		vosk.start_listening()

func stop():
	if vosk and vosk.has_method("stop_listening"):
		vosk.stop_listening()

func is_listening() -> bool:
	if vosk and vosk.has_method("is_listening"):
		return vosk.is_listening()
	return false
