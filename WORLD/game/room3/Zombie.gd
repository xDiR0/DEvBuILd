extends CharacterBody3D

@export var patrol_a: Vector3 = Vector3(-4.0, 0.2, -7.0)
@export var patrol_b: Vector3 = Vector3(4.0, 0.2, 7.0)
@export var patrol_speed: float = 0.45
@export var chase_speed: float = 0.85
@export var detect_distance: float = 7.0
@export var crouch_detect_distance: float = 2.2
@export var attack_distance: float = 1.4
@export var attack_damage: int = 35
@export var attack_cooldown: float = 1.2
@export var model_forward_y_degrees: float = 180.0

@onready var zombie_mesh: Node3D = $ZombieMesh

var patrol_target: Vector3
var attack_timer = 0.0
var gravity = 9.8
var animation_player: AnimationPlayer
var idle_animation = ""
var walk_animation = ""

func _ready():
	patrol_target = patrol_b
	animation_player = find_animation_player(self)
	find_animation_names()
	play_idle()

func _physics_process(delta):
	if attack_timer > 0.0:
		attack_timer -= delta

	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	var player = get_tree().get_first_node_in_group("player")
	var player_3d = player as Node3D
	if player_3d and can_detect_player(player_3d):
		chase_player(player_3d)
	else:
		patrol()

	move_and_slide()

func can_detect_player(player: Node3D) -> bool:
	var distance = global_position.distance_to(player.global_position)
	var player_crouching = player.get("is_crouching") == true
	var active_detect_distance = crouch_detect_distance if player_crouching else detect_distance
	return distance <= active_detect_distance

func chase_player(player: Node3D):
	var to_player = player.global_position - global_position
	to_player.y = 0.0

	if to_player.length() <= attack_distance:
		velocity.x = move_toward(velocity.x, 0.0, chase_speed)
		velocity.z = move_toward(velocity.z, 0.0, chase_speed)
		play_idle()
		attack_player(player)
		return

	move_towards(to_player.normalized(), chase_speed)

func patrol():
	var to_target = patrol_target - global_position
	to_target.y = 0.0

	if to_target.length() < 0.4:
		patrol_target = patrol_a if patrol_target == patrol_b else patrol_b
		to_target = patrol_target - global_position
		to_target.y = 0.0

	if to_target.length() > 0.0:
		move_towards(to_target.normalized(), patrol_speed)

func move_towards(direction: Vector3, move_speed: float):
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed
	look_at(global_position + direction, Vector3.UP)
	zombie_mesh.rotation.y = deg_to_rad(model_forward_y_degrees)
	play_walk()

func attack_player(player: Node3D):
	if attack_timer > 0.0:
		return

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)
	attack_timer = attack_cooldown

func find_animation_player(node: Node) -> AnimationPlayer:
	if node is AnimationPlayer:
		return node

	for child in node.get_children():
		var found = find_animation_player(child)
		if found:
			return found

	return null

func find_animation_names():
	if animation_player == null:
		return

	for anim_name in animation_player.get_animation_list():
		var lower_name = String(anim_name).to_lower()
		if walk_animation == "" and ("walk" in lower_name or "run" in lower_name):
			walk_animation = anim_name
		if idle_animation == "" and "idle" in lower_name:
			idle_animation = anim_name

	if walk_animation == "" and animation_player.get_animation_list().size() > 0:
		walk_animation = animation_player.get_animation_list()[0]
	if idle_animation == "":
		idle_animation = walk_animation

func play_walk():
	play_animation(walk_animation)

func play_idle():
	play_animation(idle_animation)

func play_animation(anim_name: String):
	if animation_player == null or anim_name == "":
		return

	if animation_player.current_animation != anim_name:
		animation_player.play(anim_name)
