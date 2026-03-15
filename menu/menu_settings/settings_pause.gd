extends Control

@onready var settings: VBoxContainer = $SETTINGS
@onready var screen: Panel = $SCREEN
@onready var sound: Panel = $SOUND

# Переменная для отслеживания откуда открыто меню
var from_game: bool = false
# Ссылка на меню паузы (если есть)
var pause_menu = null

func _ready() -> void:
	show_main_settings()

func show_main_settings():
	settings.visible = true
	screen.visible = false
	sound.visible = false

func _process(delta: float) -> void:
	# Проверяем нажатие ESC для закрытия меню
	if Input.is_action_just_pressed("ui_cancel") and from_game:
		close_menu()

func close_menu():
	if from_game:
		# Возвращаемся в меню паузы
		hide()
		if pause_menu:
			pause_menu.show()
		else:
			# Если нет ссылки на меню паузы, ищем его
			var player = get_parent()
			if player.has_method("show_pause_menu"):
				player.show_pause_menu()
	else:
		# Возвращаемся в главное меню
		get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func _on_back_pressed() -> void:
	close_menu()

func _on_sound_pressed() -> void:
	settings.visible = false
	sound.visible = true

func _on_control_pressed() -> void:
	# Добавьте логику для управления, если нужно
	pass

func _on_graphics_pressed() -> void:
	# Добавьте логику для графики, если нужно
	pass

func _on_screen_pressed() -> void:
	settings.visible = false
	screen.visible = true

func _on_back_options_pressed() -> void:
	show_main_settings()

# Метод для открытия меню из игры (из меню паузы)
func open_from_game(pause_menu_ref = null):
	from_game = true
	pause_menu = pause_menu_ref
	show_main_settings()
	show()

# Метод для сброса состояния
func reset():
	from_game = false
	pause_menu = null
	show_main_settings()
