extends CharacterBody3D

@export var speed : float = 5.0
@export var gravity : float = 9.8
@export var jump_height : float = 1 
@export var mouse_sensitivity : float = 0.002

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_animations: AnimationPlayer = $Camera_animations



func _ready():
# Импорт мыши //
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
func _input(event):
	if event is InputEventMouseMotion:
		camera_3d.rotation.x -= event.relative.y * mouse_sensitivity
		rotation.x = clamp(rotation.x, -1.5, 1.5)
		
		# ГОРИЗОНТАЛЬ (влево/вправо) - вращаем персонажа
		rotation.y -= event.relative.x * mouse_sensitivity
func _physics_process(delta):


# блок логики //
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and jump_height > 0: # "ui_accept" это пробел по умолчанию
		velocity.y = sqrt(2 * gravity * jump_height)
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * speed
		velocity.z = direction.z * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.z = move_toward(velocity.z, 0, speed)
		
# Блок анимаций //
	if Input.get_vector("left", "right", "forward", "back"):
		camera_animations.play("walk")
	else: 
		camera_animations.play("idle")
		
		
	move_and_slide()
