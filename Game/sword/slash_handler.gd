extends Node2D

@export var projectile_scene: PackedScene

var can_slash := true
var slash_active := false
var slash_progress := 0.0
var slash_direction := 1

var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var slash_rotation := 0.0

var stats: StatsComponent


func _on_slash_fired(pos: Vector2, dir: Vector2) -> void:
	print("Slash fired at ", pos, " in direction ", dir)

	if not can_slash:
		print("Slash unsuccessful!")
		return

	can_slash = false
	slash_active = true
	base_pos = pos
	base_dir = dir
	_start_slash_timers()
	
	var final_duration := get_final_slash_duration()
	var spawn_timer = get_tree().create_timer(final_duration / 4.0)
	spawn_timer.timeout.connect(func():
		spawn_projectile(pos, dir)
	)


func spawn_projectile(pos: Vector2, dir: Vector2) -> void:
	if not projectile_scene:
		push_warning("Projectile scene not assigned in SlashHandler!")
		return

	var projectile = projectile_scene.instantiate()

	var sword = get_parent()
	var spawn_distance = sword.distance + 25.0
	var spawn_pos = pos + dir * spawn_distance

	projectile.global_position = spawn_pos
	projectile.direction = dir
	projectile.lifetime = get_final_slash_duration()
	projectile.size = get_final_slash_size()
	projectile.damage = get_final_slash_damage()
	projectile.scale.y = abs(projectile.scale.y) * slash_direction * -1
	get_tree().current_scene.add_child(projectile)


func _process(delta):
	var final_duration := get_final_slash_duration()

	if not slash_active and slash_progress <= 0.0:
		slash_rotation = 0.0
		return

	if final_duration <= 0.0:
		slash_progress = 1.0 if slash_active else 0.0
	else:
		if slash_active:
			slash_progress = min(slash_progress + delta / final_duration, 1.0)
		else:
			slash_progress = max(slash_progress - delta / final_duration, 0.0)

	slash_rotation = slash_direction * get_final_slash_angle() * sin(slash_progress * PI)


func _start_slash_timers() -> void:
	var final_duration := get_final_slash_duration()
	var final_cooldown := get_final_slash_cooldown()

	var anim_timer = get_tree().create_timer(final_duration)
	anim_timer.timeout.connect(_on_slash_animation_finished)

	var cooldown_timer = get_tree().create_timer(final_cooldown)
	cooldown_timer.timeout.connect(_on_slash_cooldown_finished)


func _on_slash_animation_finished() -> void:
	slash_active = false
	slash_direction *= -1
	slash_rotation = 0.0


func _on_slash_cooldown_finished() -> void:
	can_slash = true


func get_final_slash_damage() -> int:
	if stats == null:
		return 1

	return int(stats.calculate_stat(&"slash_damage"))


func get_final_slash_size() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"slash_size")


func get_final_slash_duration() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"slash_duration")


func get_final_slash_cooldown() -> float:
	if stats == null:
		return 0.01

	return stats.calculate_stat(&"slash_cooldown")


func get_final_slash_angle() -> float:
	if stats == null:
		return 0.0

	return stats.calculate_stat(&"slash_angle")


func _get_add(stat_name: StringName) -> float:
	if stats == null:
		return 0.0
	return stats.get_add(stat_name)


func _get_mult(stat_name: StringName) -> float:
	if stats == null:
		return 1.0
	return stats.get_mult(stat_name)
