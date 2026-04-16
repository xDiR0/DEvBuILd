extends CharacterBody3D
# Переменные 
var can_move = false
@export var speed : float = 2.5
@export var gravity : float = 9.8
@export var jump_height : float = 0.8 
@export var mouse_sensitivity : float = 0.002
@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_animations: AnimationPlayer = $Camera_animations
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
var camera_rotation_x = 0.0


func _ready():
	add_to_group("player")
	teleport_to_spawn()
func teleport_to_spawn():
	# Ищем точку спавна в текущей сцене
	var spawn_node = get_tree().root.get_node_or_null(str(get_tree().current_scene.get_path()) + "/" + Global.spawn_point_name)
	if spawn_node:
		global_position = spawn_node.global_position
	Global.spawn_point_name = "start"
	camera_animations.animation_finished.connect(_on_animation_finished)
	# ========== ПРОВЕРКА КОМНАТЫ ДЛЯ WAKE_UP ==========
	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "Room1":
		camera_animations.play("wake_up")
		start_blinking()
	else:
		print("Игрок не в Room1, анимация пропущена")
		can_move = true  # Сразу разрешаем движение
	# =================================================
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func start_blinking():
	await get_tree().process_frame
	var blink_rect = ColorRect.new()
	blink_rect.color = Color(0, 0, 0, 1)
	blink_rect.size = get_viewport().size
	blink_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().add_child(blink_rect)
	var tween = create_tween().set_loops(3)
	tween.tween_property(blink_rect, "color:a", 0.0, 1)
	tween.tween_property(blink_rect, "color:a", 1.0, 1)
	tween.tween_interval(1)
	tween.finished.connect(blink_rect.queue_free)
func _on_animation_finished(anim_name: String):
	if anim_name == "wake_up":
		can_move = true
func _input(event):
	# КАМЕРА
	if event is InputEventMouseMotion and can_move:
		camera_rotation_x -= event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.5)
		camera_3d.rotation.x = camera_rotation_x
		rotation.y -= event.relative.x * mouse_sensitivity
func _physics_process(delta):
	if not can_move:
		return
	
	# блок логики (двигаться)
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and jump_height > 0:
		velocity.y = sqrt(2 * gravity * jump_height)
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
	
	# Блок анимаций(камеры)
	if input_dir != Vector2.ZERO:
		camera_animations.play("walk")
	else: 
		camera_animations.play("idle")
	
	move_and_slide()
