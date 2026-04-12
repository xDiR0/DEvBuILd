extends StaticBody3D
@onready var animation_player: AnimationPlayer = $"../../AnimationPlayer"
@onready var activate_zone: Area3D = $"../ActivateZone"

var player_in_zone = false
var is_open = false
var is_animating = false

# Called when the node enters the scene tree for the first time.
func _ready():
	# Подключаю зону активации
	if activate_zone:
		activate_zone.body_entered.connect(_on_player_entered)
		activate_zone.body_exited.connect(_on_player_exited)
	# Подключаю VoiceManager
	var vm = get_node_or_null("/root/VoiceManager")
	if vm:
		vm.voice_command_detected.connect(_on_voice_command)
	# Подключаю сигнал завершения анимации
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)
# Проверка входа в зону
func _on_player_entered(body: Node):
	if body.name == "Player":
		player_in_zone = true
		print("Говори...")

func _on_player_exited(body: Node):
	if body.name == "Player":
		player_in_zone = false
		print("Подойди ближе...")
# Called every frame. 'delta' is the elapsed time since the previous frame.
# Получение команды
func _on_voice_command(cmd: String):
	if not player_in_zone:
		print("Ещё ближе...")
		return
	
	if is_animating:
		return
	
	if cmd == "open" and not is_open:
		is_animating = true
		animation_player.play("Chest_room2")
# Когда анимация закончилась
func _on_animation_finished(anim_name: String):
	is_animating = false
	if anim_name == "Chest_room2":
		is_open = true
