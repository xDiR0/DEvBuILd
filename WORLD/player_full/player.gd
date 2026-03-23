extends CharacterBody3D

var can_move = false
@export var speed : float = 2.5
@export var gravity : float = 9.8
@export var jump_height : float = 0.8 
@export var mouse_sensitivity : float = 0.002

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_animations: AnimationPlayer = $Camera_animations

var camera_rotation_x = 0.0

func _ready():
	# Подключаем сигнал окончания анимации
	camera_animations.animation_finished.connect(_on_animation_finished)
	
	# Запускаем анимацию пробуждения
	camera_animations.play("wake_up")
	
	# Импорт мыши
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _on_animation_finished(anim_name):
	if anim_name == "wake_up":
		can_move = true

func _input(event):
	if event is InputEventMouseMotion and can_move:
		# ВЕРТИКАЛЬ (вверх/вниз) - вращаем камеру
		camera_rotation_x -= event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.5)
		camera_3d.rotation.x = camera_rotation_x
		
		# ГОРИЗОНТАЛЬ (влево/вправо) - вращаем персонажа
		rotation.y -= event.relative.x * mouse_sensitivity

func _physics_process(delta):
	if not can_move:
		return
	
	# блок логики
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
	
	# Блок анимаций
	if input_dir != Vector2.ZERO:
		camera_animations.play("walk")
	else: 
		camera_animations.play("idle")
	
	move_and_slide()
