extends Node3D

@onready var activation_zone: Area3D = $ActivationZone
@onready var door_pivot = $DoorPivot
@onready var door_animations: AnimationPlayer = $DoorPivot/Door_animations

var player_in_zone = false
var is_open = false
var is_animating = false

func _ready():
	# Подключаю зону активации
	if activation_zone:
		activation_zone.body_entered.connect(_on_player_entered)
		activation_zone.body_exited.connect(_on_player_exited)
	# Подключаю VoiceManager
	var vm = get_node_or_null("/root/VoiceManager")
	if vm:
		vm.voice_command_detected.connect(_on_voice_command)
	# Подключаю сигнал завершения анимации
	if door_animations:
		door_animations.animation_finished.connect(_on_animation_finished)

# Проверка входа в зону
func _on_player_entered(body: Node):
	if body.name == "Player":
		player_in_zone = true
		print("Говори...")

func _on_player_exited(body: Node):
	if body.name == "Player":
		player_in_zone = false
		print("Подойди ближе...")

# Получение команды
func _on_voice_command(cmd: String):
	# Проверка в зоне ли игрок
	if not player_in_zone:
		print("Ещё ближе...")
		return
	
	# Проверка на анимацию двери
	if is_animating:
		return
	
	# Выполняем команду
	if cmd == "open" and not is_open:
		is_animating = true
		door_animations.play("open")
	elif cmd == "close" and is_open:
		is_animating = true
		door_animations.play("close")

# Когда анимация закончилась
func _on_animation_finished(anim_name: String):
	is_animating = false
