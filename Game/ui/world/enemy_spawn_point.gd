extends Node2D
class_name EnemySpawnPoint

@export var enemy_scene: PackedScene
@export var respawn_time: float = 5.0
@export var spawn_on_ready: bool = true
@export var initial_spawn_delay: float = 0.0
@export var max_respawns: int = -1
@export var block_spawn_if_player_inside: bool = true
@export var spawn_parent_path: NodePath

@onready var spawn_area: Area2D = $SpawnArea
@onready var collision_shape: CollisionShape2D = $SpawnArea/CollisionShape2D
@onready var respawn_timer: Timer = $RespawnTimer

var current_enemy: Node2D = null
var respawns_done: int = 0

func _ready() -> void:
	respawn_timer.one_shot = true
	respawn_timer.timeout.connect(_try_spawn)

	if spawn_on_ready:
		if initial_spawn_delay > 0.0:
			respawn_timer.start(initial_spawn_delay)
		else:
			_try_spawn()

func _try_spawn() -> void:
	if current_enemy != null:
		return

	if enemy_scene == null:
		push_warning("EnemySpawnPoint has no enemy_scene assigned.")
		return

	if max_respawns >= 0 and respawns_done >= max_respawns:
		return

	if block_spawn_if_player_inside and _is_player_in_spawn_area():
		respawn_timer.start(1.0)
		return

	var enemy := enemy_scene.instantiate() as Node2D
	if enemy == null:
		push_warning("Spawned scene is not a Node2D.")
		return

	_get_spawn_parent().add_child(enemy)
	enemy.global_position = _get_random_spawn_position()
	current_enemy = enemy

	if enemy.has_signal("defeated"):
		enemy.defeated.connect(_on_enemy_defeated)
	else:
		push_warning("Spawned enemy has no defeated signal.")

func _on_enemy_defeated(enemy: Node) -> void:
	if enemy != current_enemy:
		return

	current_enemy = null
	respawns_done += 1
	respawn_timer.start(respawn_time)

func _get_spawn_parent() -> Node:
	if spawn_parent_path != NodePath():
		var target := get_node_or_null(spawn_parent_path)
		if target != null:
			return target
	return self

func _get_random_spawn_position() -> Vector2:
	var rect := collision_shape.shape as RectangleShape2D
	if rect == null:
		return global_position

	var half_size := rect.size * 0.5
	var local_point := Vector2(
		randf_range(-half_size.x, half_size.x),
		randf_range(-half_size.y, half_size.y)
	)

	return collision_shape.to_global(local_point)

func _is_player_in_spawn_area() -> bool:
	for body in spawn_area.get_overlapping_bodies():
		if body.is_in_group("player"):
			return true
	return false
