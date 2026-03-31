extends Node2D

@export var projectile_scene: PackedScene
@export var stats_path: NodePath

# BASE STATS
@export var slash_angle := deg_to_rad(150.0)
@export var slash_duration := 0.1
@export var slash_cooldown := 0.7
@export var slash_size := 1.0
@export var slash_damage := 1.0

var can_slash := true
var slash_active := false
var slash_progress := 0.0
var slash_direction := 1

var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var slash_rotation := 0.0

var stats: StatsComponent


func _ready() -> void:
	if stats_path != NodePath():
		stats = get_node_or_null(stats_path) as StatsComponent


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
	var base: float = slash_damage
	var add: float = _get_add(&"slash_damage")
	var mult: float = _get_mult(&"slash_damage")
	return max(1, int(round((base + add) * mult)))


func get_final_slash_size() -> float:
	var base: float = slash_size
	var add: float = _get_add(&"slash_size")
	var mult: float = _get_mult(&"slash_size")
	return max(0.01, (base + add) * mult)


func get_final_slash_duration() -> float:
	var base: float = slash_duration
	var add: float = _get_add(&"slash_duration")
	var mult: float = _get_mult(&"slash_duration")
	return max(0.01, (base + add) * mult)


func get_final_slash_cooldown() -> float:
	var base: float = slash_cooldown
	var add: float = _get_add(&"slash_cooldown")
	var mult: float = _get_mult(&"slash_cooldown")
	return max(0.01, (base + add) * mult)


func get_final_slash_angle() -> float:
	var base: float = slash_angle
	var add: float = _get_add(&"slash_angle")
	var mult: float = _get_mult(&"slash_angle")
	return max(0.0, (base + add) * mult)


func _get_add(stat_name: StringName) -> float:
	if stats == null:
		return 0.0
	return stats.get_add(stat_name)


func _get_mult(stat_name: StringName) -> float:
	if stats == null:
		return 1.0
	return stats.get_mult(stat_name)
