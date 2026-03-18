@tool
extends EditorPlugin

func _enter_tree():
	# Регистрируем тип без иконки
	add_custom_type("VoskVoiceRecognition", "Node", preload("vosk_node.gd"), null)
	print("Vosk plugin loaded")

func _exit_tree():
	# Удаляем тип
	remove_custom_type("VoskVoiceRecognition")
	print("Vosk plugin unloaded")
