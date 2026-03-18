extends Node

var _vosk = null

func _ready():
	# Пытаемся создать экземпляр
	if ClassDB.class_exists("VoskVoiceRecognition"):
		_vosk = ClassDB.instantiate("VoskVoiceRecognition")
		if _vosk:
			add_child(_vosk)
			print("Vosk node created")
	else:
		print("VoskVoiceRecognition class not found")

func initialize(model_path: String) -> bool:
	if _vosk and _vosk.has_method("initialize"):
		return _vosk.initialize(model_path)
	return false

func get_input_devices() -> Array:
	if _vosk and _vosk.has_method("get_input_devices"):
		return _vosk.get_input_devices()
	return []

func set_input_device(index: int):
	if _vosk and _vosk.has_method("set_input_device"):
		_vosk.set_input_device(index)

func start_listening():
	if _vosk and _vosk.has_method("start_listening"):
		_vosk.start_listening()

func stop_listening():
	if _vosk and _vosk.has_method("stop_listening"):
		_vosk.stop_listening()

func is_listening() -> bool:
	if _vosk and _vosk.has_method("is_listening"):
		return _vosk.is_listening()
	return false

# Сигналы
func _notification(what):
	if what == NOTIFICATION_READY and _vosk:
		if _vosk.has_signal("partial_result"):
			_vosk.partial_result.connect(_on_partial_result)
		if _vosk.has_signal("final_result"):
			_vosk.final_result.connect(_on_final_result)

func _on_partial_result(text):
	print("Partial: ", text)

func _on_final_result(text):
	print("Final: ", text)