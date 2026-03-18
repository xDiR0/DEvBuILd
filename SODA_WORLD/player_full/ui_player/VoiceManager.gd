extends Node

signal voice_command_detected(command)
signal voice_volume_changed(volume)

var vosk_node = null
var mic_bus_index: int
var mic_player: AudioStreamPlayer

func _ready():
	_setup_microphone()
	call_deferred("_setup_vosk")
	add_to_group("voice_manager")

func _setup_microphone():
	mic_bus_index = AudioServer.get_bus_index("MicBus")
	if mic_bus_index == -1:
		AudioServer.add_bus()
		mic_bus_index = AudioServer.bus_count - 1
		AudioServer.set_bus_name(mic_bus_index, "MicBus")
	
	AudioServer.set_bus_volume_db(mic_bus_index, 30.0)
	AudioServer.add_bus_effect(mic_bus_index, AudioEffectRecord.new(), 0)
	
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

func _setup_vosk():
	if not ClassDB.class_exists("VoskVoiceRecognition"):
		return
	
	vosk_node = ClassDB.instantiate("VoskVoiceRecognition")
	if not vosk_node:
		return
	
	add_child(vosk_node)
	await get_tree().create_timer(0.5).timeout
	
	var devices = vosk_node.get_input_devices()
	if devices.size() > 4:
		vosk_node.set_input_device(4)
	
	var model_path = "D:/Github/DEvBuILd/models/vosk-model-small-en-us-0.15"
	var result = vosk_node.initialize(model_path)
	
	if result:
		vosk_node.final_result_signal.connect(_on_vosk_final)
		vosk_node.start()

func _on_vosk_final(recognized_text: String):
	var lower_text = recognized_text.to_lower()
	
	if "open" in lower_text and "door" in lower_text:
		emit_signal("voice_command_detected", "open")
	elif "close" in lower_text and "door" in lower_text:
		emit_signal("voice_command_detected", "close")

func _check_volume():
	var db = AudioServer.get_bus_peak_volume_left_db(mic_bus_index, 0)
	var linear = db_to_linear(db)
	emit_signal("voice_volume_changed", min(linear, 1.0))

func get_volume() -> float:
	var db = AudioServer.get_bus_peak_volume_left_db(mic_bus_index, 0)
	return min(db_to_linear(db), 1.0)
