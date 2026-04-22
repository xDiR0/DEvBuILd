extends CharacterBody3D

signal health_changed(current_health)
signal died

var can_move = false
var camera_rotation_x = 0.0
var is_crouching = false

@export var speed: float = 2.5
@export var crouch_speed: float = 1.3
@export var gravity: float = 9.8
@export var jump_height: float = 0.8
@export var mouse_sensitivity: float = 0.002
@export var max_health: int = 100
@export var damage_cooldown: float = 0.5
@export var fall_death_y: float = -12.0

@onready var camera_3d: Camera3D = $Camera3D
@onready var camera_animations: AnimationPlayer = $Camera_animations
@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D

var current_health: int
var damage_timer: float = 0.0
var standing_camera_height: float = 1.6
var crouching_camera_height: float = 0.95
var standing_collision_height: float = 2.0
var crouching_collision_height: float = 1.15
var is_dead = false
var death_fade: ColorRect

func _ready():
	add_to_group("player")
	current_health = max_health

	if collision_shape_3d.shape is CapsuleShape3D:
		standing_collision_height = collision_shape_3d.shape.height

	if not camera_animations.animation_finished.is_connected(_on_animation_finished):
		camera_animations.animation_finished.connect(_on_animation_finished)

	var saved_data = Global.consume_pending_player_data()
	if Global.force_fresh_start:
		Global.force_fresh_start = false
		reset_for_new_game()
	elif saved_data.is_empty():
		teleport_to_spawn()
	else:
		apply_saved_data(saved_data)

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	health_changed.emit(current_health)

func reset_for_new_game():
	current_health = max_health
	is_dead = false
	can_move = false
	velocity = Vector3.ZERO
	camera_rotation_x = 0.0
	is_crouching = false
	rotation = Vector3.ZERO
	camera_3d.rotation = Vector3.ZERO
	camera_3d.position = Vector3(0, standing_camera_height, 0)
	Global.spawn_point_name = "start"
	teleport_to_spawn()

func teleport_to_spawn():
	var spawn_node = get_tree().root.get_node_or_null(str(get_tree().current_scene.get_path()) + "/" + Global.spawn_point_name)
	if spawn_node:
		global_position = spawn_node.global_position

	Global.spawn_point_name = "start"

	var current_scene_name = get_tree().current_scene.name
	if current_scene_name == "Room1":
		camera_animations.play("wake_up")
		start_blinking()
	else:
		can_move = true

func apply_saved_data(saved_data: Dictionary):
	global_position = saved_data.get("position", global_position)
	rotation.y = saved_data.get("rotation_y", rotation.y)
	camera_rotation_x = saved_data.get("camera_rotation_x", camera_rotation_x)
	camera_3d.position = saved_data.get("camera_position", camera_3d.position)
	camera_3d.rotation = saved_data.get("camera_rotation", camera_3d.rotation)
	current_health = clampi(saved_data.get("current_health", max_health), 0, max_health)
	can_move = current_health > 0

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
	if event is InputEventMouseMotion and can_move:
		camera_rotation_x -= event.relative.y * mouse_sensitivity
		camera_rotation_x = clamp(camera_rotation_x, -1.5, 1.5)
		camera_3d.rotation.x = camera_rotation_x
		rotation.y -= event.relative.x * mouse_sensitivity

func _unhandled_input(event):
	if event.is_action_pressed("game_pause"):
		get_viewport().set_input_as_handled()
		toggle_pause()
	elif event.is_action_pressed("debug_damage") and OS.is_debug_build():
		take_damage(10)

func _physics_process(delta):
	if damage_timer > 0.0:
		damage_timer -= delta

	if global_position.y <= fall_death_y:
		die()
		return

	if not can_move:
		return

	is_crouching = Input.is_action_pressed("crouch")

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		if velocity.y < 0:
			velocity.y = 0

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and jump_height > 0 and not is_crouching:
		velocity.y = sqrt(2 * gravity * jump_height)

	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	var move_speed = crouch_speed if is_crouching else speed

	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)

	if is_crouching:
		camera_animations.stop()
	elif input_dir != Vector2.ZERO:
		camera_animations.play("walk")
	else:
		camera_animations.play("idle")

	update_crouch(delta)
	move_and_slide()

func update_crouch(delta: float):
	var target_camera_height = crouching_camera_height if is_crouching else standing_camera_height
	camera_3d.position.y = lerpf(camera_3d.position.y, target_camera_height, min(delta * 10.0, 1.0))

	if collision_shape_3d.shape is CapsuleShape3D:
		var capsule := collision_shape_3d.shape as CapsuleShape3D
		var target_height = crouching_collision_height if is_crouching else standing_collision_height
		capsule.height = lerpf(capsule.height, target_height, min(delta * 12.0, 1.0))

func take_damage(amount: int):
	if amount <= 0 or current_health <= 0 or damage_timer > 0.0 or is_dead:
		return

	current_health = clampi(current_health - amount, 0, max_health)
	damage_timer = damage_cooldown
	health_changed.emit(current_health)

	if current_health == 0:
		die()

func heal(amount: int):
	if amount <= 0 or current_health <= 0:
		return

	current_health = clampi(current_health + amount, 0, max_health)
	health_changed.emit(current_health)

func die():
	if is_dead:
		return

	is_dead = true
	can_move = false
	velocity = Vector3.ZERO
	current_health = 0
	health_changed.emit(current_health)
	died.emit()
	show_death_fade()
	return_to_menu_after_death()

func show_death_fade():
	death_fade = ColorRect.new()
	death_fade.color = Color(0, 0, 0, 0)
	death_fade.size = get_viewport().size
	death_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	get_viewport().add_child(death_fade)

	var tween = create_tween()
	tween.tween_property(death_fade, "color:a", 1.0, 0.4)

func return_to_menu_after_death():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(death_fade):
		death_fade.queue_free()
	get_tree().paused = false
	Global.pending_player_data.clear()
	Global.spawn_point_name = "start"
	Global.settings_return_to_game = false
	Global.force_fresh_start = false
	get_tree().change_scene_to_file("res://menu/main_menu/main_menu.tscn")

func toggle_pause():
	var pause_menu = get_tree().get_first_node_in_group("pause_menu")
	if pause_menu and pause_menu.has_method("toggle_pause"):
		pause_menu.toggle_pause()
