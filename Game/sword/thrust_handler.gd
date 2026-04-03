extends Node2D

@export var projectile_scene: PackedScene

var can_fire := true
var thrust_progress := 0.0
var thrust_active := false
var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var thrust_offset := 0.0

var stats: StatsComponent


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
	var player = sword.get_parent()

	projectile.instigator = player
	projectile.faction = player.faction
	var final_distance_multiplier := get_final_thrust_distance_multiplier()
	var spawn_distance = sword.distance * final_distance_multiplier + 25.0

	var spawn_pos = pos + dir * spawn_distance

	projectile.global_position = spawn_pos
	projectile.direction = dir
	projectile.lifetime = get_final_thrust_duration()
	projectile.size = get_final_thrust_size()
	projectile.damage = get_final_thrust_damage()
	projectile.reach_from_player = spawn_distance
	
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
	if stats == null:
		return 1

	return int(stats.calculate_stat(&"thrust_damage"))


func get_final_thrust_size() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"thrust_size")


func get_final_thrust_duration() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"thrust_duration")


func get_final_thrust_cooldown() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"thrust_cooldown")


func get_final_thrust_distance_multiplier() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"thrust_distance_multiplier")
