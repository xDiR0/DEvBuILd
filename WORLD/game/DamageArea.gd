extends Area3D

@export var damage: int = 10
@export var damage_interval: float = 1.0
@export var damage_once: bool = false

var bodies_in_area: Array[Node] = []
var damage_timer: float = 0.0

func _ready():
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _physics_process(delta):
	if damage_once:
		return

	damage_timer -= delta
	if damage_timer > 0.0:
		return

	for body in bodies_in_area:
		_damage_body(body)

	damage_timer = damage_interval

func _on_body_entered(body: Node):
	if not bodies_in_area.has(body):
		bodies_in_area.append(body)

	_damage_body(body)
	damage_timer = damage_interval

func _on_body_exited(body: Node):
	bodies_in_area.erase(body)

func _damage_body(body: Node):
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)
