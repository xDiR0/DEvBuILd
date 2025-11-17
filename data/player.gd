extends CharacterBody3D

# Настройки
var speed: float = 4.0
var jump_force: float = 10.5
var gravity: float = 0.98

func _physics_process(delta):
	# Гравитация
	if not is_on_floor():
		velocity.y -= gravity + delta
	
	# Прыжок
	if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
		velocity.y = jump_force
	
	# Движение
	velocity.x = 0
	velocity.z = 0
	
	if Input.is_key_pressed(KEY_W):
		velocity.x = speed
	if Input.is_key_pressed(KEY_S):
		velocity.x = -speed
	if Input.is_key_pressed(KEY_A):
		velocity.z = -speed
	if Input.is_key_pressed(KEY_D):
		velocity.z = speed
	
	move_and_slide()
