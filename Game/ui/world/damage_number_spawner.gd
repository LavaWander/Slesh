extends Node
class_name DamageNumberSpawner

@export var health_path: NodePath = ^"../HealthComponent"
@export var collision_shape_path: NodePath = ^"../CollisionShape2D"
@export var damage_number_scene: PackedScene
@export var damage_parent_group: StringName = &"world_effects"
@export var lifetime: float = 0.35
@export var rise_distance: float = 24.0
@export var spawn_jitter: Vector2 = Vector2(10.0, 6.0)

var health: HealthComponent
var collision_shape: CollisionShape2D
var host: Node2D
var damage_parent: Node

func _ready() -> void:
	host = get_parent() as Node2D
	health = get_node_or_null(health_path) as HealthComponent
	collision_shape = get_node_or_null(collision_shape_path) as CollisionShape2D
	damage_parent = get_tree().get_first_node_in_group(damage_parent_group)

	if host == null or health == null or collision_shape == null or damage_number_scene == null or damage_parent == null:
		push_warning("DamageNumberSpawner is missing setup.")
		return

	if not health.damaged.is_connected(_on_damaged):
		health.damaged.connect(_on_damaged)

func _on_damaged(amount: int, _current: int, _source: Node) -> void:
	var damage_number := damage_number_scene.instantiate() as DamageNumber
	damage_parent.add_child(damage_number)

	# Make it render in global canvas space instead of inheriting the enemy transform.
	damage_number.top_level = true
	damage_number.z_as_relative = false

	var health_bar := host.get_node_or_null("EnemyHealthBar") as CanvasItem
	if health_bar != null:
		damage_number.z_index = health_bar.z_index + 1
	else:
		damage_number.z_index = 2

	damage_number.setup(amount, lifetime, rise_distance)

	var local_spawn := _get_upper_half_center_local() + Vector2(
		randf_range(-spawn_jitter.x, spawn_jitter.x),
		randf_range(-spawn_jitter.y, spawn_jitter.y)
	)

	damage_number.global_position = host.to_global(local_spawn) - (damage_number.size * 0.5)



func _get_upper_half_center_local() -> Vector2:
	return Vector2(
		collision_shape.position.x,
		collision_shape.position.y - (_get_half_height() * 0.5)
	)

func _get_half_height() -> float:
	if collision_shape.shape is RectangleShape2D:
		return (collision_shape.shape as RectangleShape2D).size.y * 0.5

	if collision_shape.shape is CapsuleShape2D:
		var capsule := collision_shape.shape as CapsuleShape2D
		return (capsule.height * 0.5) + capsule.radius

	if collision_shape.shape is CircleShape2D:
		return (collision_shape.shape as CircleShape2D).radius

	return 16.0
