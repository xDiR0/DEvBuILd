extends Control

@onready var settings: VBoxContainer = $SETTINGS
@onready var screen: Panel = $SCREEN
@onready var sound: Panel = $SOUND

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	settings.visible = true
	screen.visible = false
	sound.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")




func _on_sound_pressed() -> void:
	settings.visible = false
	sound.visible = true
func _on_control_pressed() -> void:
	pass
func _on_graphics_pressed() -> void:
	pass
func _on_screen_pressed() -> void:
	settings.visible = false
	screen.visible = true

func _on_back_options_pressed() -> void:
	_ready()
