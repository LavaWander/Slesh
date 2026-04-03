extends Node2D

var direction := Vector2.RIGHT
var hit_enemies := []

var instigator: Node = null
var faction := ""

var speed := 0
var lifetime := 1.0 # default, should be changed by ThrustHandler
var size := 1.0 # default, should be changed by ThrustHandler
var damage := 1
var reach_from_player := 0.0

var elapsed := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D
@onready var attack: AttackComponent = $AttackComponent

var base_collision_size := Vector2.ZERO
var base_collision_position := Vector2.ZERO

func _ready():
	var rect := collision_shape.shape as RectangleShape2D
	if rect == null:
		push_warning("Thrust expects a RectangleShape2D hitbox.")
		return

	rect = rect.duplicate()
	collision_shape.shape = rect

	base_collision_size = rect.size
	base_collision_position = collision_shape.position

	scale *= Vector2(size, size)
	_extend_hitbox_to_player()

	var frame_count = sprite.sprite_frames.get_frame_count("default")
	sprite.speed_scale = frame_count / lifetime
	sprite.play("default")

	attack.configure(damage, instigator, faction)
	area.body_entered.connect(_on_body_entered)

func _process(delta):
	elapsed += delta

	position += direction * speed * delta
	rotation = direction.angle()

	if elapsed >= lifetime:
		queue_free()

func _on_body_entered(body):
	attack.try_hit(body)

func _extend_hitbox_to_player() -> void:
	var rect: RectangleShape2D = collision_shape.shape as RectangleShape2D
	if rect == null:
		return

	var scale_x: float = absf(scale.x)
	if is_zero_approx(scale_x):
		scale_x = 1.0

	var base_back_reach_world: float = (base_collision_size.x * 0.5 - base_collision_position.x) * scale_x
	var extra_back_reach_world: float = maxf(0.0, reach_from_player - base_back_reach_world)
	var extra_back_reach_local: float = extra_back_reach_world / scale_x

	rect.size.x = base_collision_size.x + extra_back_reach_local
	collision_shape.position.x = base_collision_position.x - extra_back_reach_local * 0.5
