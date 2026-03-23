extends Control
@onready var hp_indicator: Control = $HPIndicator
@onready var microphone_indicator: Control = $MicrophoneIndicator


func hide_all_ui():
	"""Скрывает весь интерфейс"""
	microphone_indicator.visible = false
	hp_indicator.visible = false
func show_all_ui():
	"""Показывает весь интерфейс"""
	microphone_indicator.visible = true
	hp_indicator.visible = true
