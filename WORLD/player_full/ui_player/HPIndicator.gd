extends Control

# Новые узлы для HP
@onready var hp_bar = $HPBar
@onready var hp_label = $HPLabel
var player
func _ready():
	# Ищем игрока
	player = get_tree().get_root().find_child("Player", true, false)
	
	if player:
		# Подключаемся к сигналу здоровья
		if player.has_signal("health_changed"):
			player.health_changed.connect(_update_hp)
			
			# Настраиваем HP элементы
			hp_bar.max_value = player.max_health
			hp_bar.value = player.current_health
			_update_hp_label(player.current_health)
			
			print("HP система подключена! Max HP: ", player.max_health)
		else:
			print("У игрока нет сигнала health_changed!")
			hp_label.text = "HP Error: сигнал не найден"
	else:
		print("Игрок не найден!")
		hp_label.text = "HP Error: игрок не найден"

func _update_hp(current_health):
	# Обновляем полоску
	hp_bar.value = current_health
	
	# Обновляем текстовую метку
	_update_hp_label(current_health)
	
	# Меняем цвет в зависимости от здоровья
	var percent = float(current_health) / float(player.max_health)
	if percent <= 0.3:
		hp_bar.modulate = Color.RED
		hp_label.add_theme_color_override("font_color", Color.RED)
	elif percent <= 0.6:
		hp_bar.modulate = Color.ORANGE
		hp_label.add_theme_color_override("font_color", Color.ORANGE)
	else:
		hp_bar.modulate = Color.WHITE
		hp_label.add_theme_color_override("font_color", Color.WHITE)

func _update_hp_label(current_health):
	hp_label.text = "❤️ HP: " + str(current_health) + " / " + str(player.max_health)
