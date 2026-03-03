extends CharacterBody3D

@export var speed : float = 5.0
@export var gravity : float = 9.8
@export var jump_height : float = 1 
@export var mouse_sensitivity : float = 0.002

func _ready():

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

		rotate_y(-event.relative.x * mouse_sensitivity)

		$Camera3D.rotate_x(-event.relative.y * mouse_sensitivity)

		$Camera3D.rotation.x = clamp($Camera3D.rotation.x, -1.5, 1.5) # Примерно -80 до 80 градусов

func _physics_process(delta):
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
	move_and_slide()
