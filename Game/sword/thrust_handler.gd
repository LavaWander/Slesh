extends Node2D

@export var projectile_scene: PackedScene
@export var stats_path: NodePath

# BASE STATS
@export var thrust_distance_multiplier := 4.0
@export var thrust_duration := 0.1
@export var thrust_cooldown := 0.5
@export var thrust_size := 1.0
@export var thrust_damage := 1.0

var can_fire := true
var thrust_progress := 0.0
var thrust_active := false
var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var thrust_offset := 0.0

var stats: StatsComponent


func _ready() -> void:
	if stats_path != NodePath():
		stats = get_node_or_null(stats_path) as StatsComponent


func _on_thrust_fired(pos: Vector2, dir: Vector2) -> void:
	print("Thrust fired at ", pos, " in direction ", dir)

	if not can_fire:
		print("Thrust unsuccessful!")
		return

	can_fire = false
	thrust_active = true
	base_pos = pos
	base_dir = dir
	spawn_projectile(pos, dir)
	_start_thrust_timers()


func spawn_projectile(pos: Vector2, dir: Vector2) -> void:
	if not projectile_scene:
		push_warning("Projectile scene not assigned in ThrustHandler!")
		return

	var projectile = projectile_scene.instantiate()

	var sword = get_parent()
	var final_distance_multiplier := get_final_thrust_distance_multiplier()
	var spawn_distance = sword.distance * final_distance_multiplier + 25.0

	var spawn_pos = pos + dir * spawn_distance

	projectile.position = spawn_pos
	projectile.direction = dir
	projectile.lifetime = get_final_thrust_duration()
	projectile.size = get_final_thrust_size()
	projectile.damage = get_final_thrust_damage()
	get_tree().current_scene.add_child(projectile)


func _process(delta):
	if not thrust_active:
		thrust_offset = 0.0
		return

	var final_duration := get_final_thrust_duration()
	var final_distance_multiplier := get_final_thrust_distance_multiplier()

	if final_duration <= 0.0:
		thrust_progress = 1.0
	else:
		thrust_progress = min(thrust_progress + delta / final_duration, 1.0)

	thrust_offset = get_parent().distance * (1.0 + (final_distance_multiplier - 1.0) * thrust_progress)


func _start_thrust_timers() -> void:
	var final_duration := get_final_thrust_duration()
	var final_cooldown := get_final_thrust_cooldown()

	var anim_timer = get_tree().create_timer(final_duration)
	anim_timer.timeout.connect(_on_thrust_animation_finished)

	var cooldown_timer = get_tree().create_timer(final_cooldown)
	cooldown_timer.timeout.connect(_on_thrust_cooldown_finished)


func _on_thrust_animation_finished() -> void:
	thrust_active = false
	thrust_progress = 0.0
	thrust_offset = 0.0


func _on_thrust_cooldown_finished() -> void:
	can_fire = true


func get_final_thrust_damage() -> int:
	var base: float = thrust_damage
	var add: float = _get_add(&"thrust_damage")
	var mult: float = _get_mult(&"thrust_damage")
	return max(1, int(round((base + add) * mult)))


func get_final_thrust_size() -> float:
	var base: float = thrust_size
	var add: float = _get_add(&"thrust_size")
	var mult: float = _get_mult(&"thrust_size")
	return max(0.01, (base + add) * mult)


func get_final_thrust_duration() -> float:
	var base: float = thrust_duration
	var add: float = _get_add(&"thrust_duration")
	var mult: float = _get_mult(&"thrust_duration")
	return max(0.01, (base + add) * mult)


func get_final_thrust_cooldown() -> float:
	var base: float = thrust_cooldown
	var add: float = _get_add(&"thrust_cooldown")
	var mult: float = _get_mult(&"thrust_cooldown")
	return max(0.01, (base + add) * mult)


func get_final_thrust_distance_multiplier() -> float:
	var base: float = thrust_distance_multiplier
	var add: float = _get_add(&"thrust_distance_multiplier")
	var mult: float = _get_mult(&"thrust_distance_multiplier")
	return max(0.01, (base + add) * mult)


func _get_add(stat_name: StringName) -> float:
	if stats == null:
		return 0.0
	return stats.get_add(stat_name)


func _get_mult(stat_name: StringName) -> float:
	if stats == null:
		return 1.0
	return stats.get_mult(stat_name)
