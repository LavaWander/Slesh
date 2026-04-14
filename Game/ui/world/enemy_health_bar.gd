extends ProgressBar
class_name EnemyHealthBar

@export var health_path: NodePath = ^"../HealthComponent"
@export var collision_shape_path: NodePath = ^"../CollisionShape2D"
@export var vertical_padding: float = 6.0 # how much space from the top of the enemy's CollisionShape2D

var health: HealthComponent
var collision_shape: CollisionShape2D


func _ready() -> void:
	var parent_canvas_item := get_parent() as CanvasItem
	if parent_canvas_item != null:
		z_as_relative = false
		z_index = parent_canvas_item.z_index + 1
		
	health = get_node_or_null(health_path) as HealthComponent
	collision_shape = get_node_or_null(collision_shape_path) as CollisionShape2D

	if health == null:
		push_warning("EnemyHealthBar could not find HealthComponent.")
		return

	if collision_shape == null:
		push_warning("EnemyHealthBar could not find CollisionShape2D.")
		return

	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)

	_place_above_enemy()
	_on_health_changed(health.current_health, health.max_health)


func _place_above_enemy() -> void:
	var bar_size := custom_minimum_size
	var top_y := collision_shape.position.y - _get_half_height()
	position = Vector2(
		collision_shape.position.x - (bar_size.x * 0.5),
		top_y - bar_size.y - vertical_padding
	)


func _get_half_height() -> float:
	if collision_shape.shape is RectangleShape2D:
		var rect := collision_shape.shape as RectangleShape2D
		return rect.size.y * 0.5

	if collision_shape.shape is CapsuleShape2D:
		var capsule := collision_shape.shape as CapsuleShape2D
		return (capsule.height * 0.5) + capsule.radius

	if collision_shape.shape is CircleShape2D:
		var circle := collision_shape.shape as CircleShape2D
		return circle.radius

	return 16.0


func _on_health_changed(current: int, max_health: int) -> void:
	max_value = max_health
	value = current
	visible = current > 0 and current < max_health
