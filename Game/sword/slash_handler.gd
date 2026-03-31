extends Node2D

@export var projectile_scene: PackedScene

# BASE STATS
@export var slash_angle := deg_to_rad(150)
@export var slash_duration := 0.1
@export var slash_cooldown := 0.7
@export var slash_size := 1.0
@export var slash_damage := 1

var can_slash := true
var slash_active := false
var slash_progress := 0.0
var slash_direction := 1

var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var slash_rotation := 0.0

func _on_slash_fired(pos: Vector2, dir: Vector2) -> void:
	print("Slash fired at ", pos, " in direction ", dir)

	if not can_slash:
		print("Slash unsuccessful!")
		return

	can_slash = false
	slash_active = true
	base_pos = pos
	base_dir = dir
	#spawn_projectile(pos, dir)
	_start_slash_timers()
	
	# delay projectile spawn by 1/3 of slash_duration
	var spawn_timer = get_tree().create_timer(slash_duration / 4)
	spawn_timer.timeout.connect(func():
		spawn_projectile(pos, dir)
	)
	
func spawn_projectile(pos: Vector2, dir: Vector2) -> void:
	if not projectile_scene:
		push_warning("Projectile scene not assigned in ThrustHandler!")
		return

	var projectile = projectile_scene.instantiate()
	
	# get sword distance
	var sword = get_parent()
	var spawn_distance = sword.distance + 25

	# calculate forward spawn position
	var spawn_pos = pos + dir * spawn_distance
	
	
	projectile.position = spawn_pos
	projectile.direction = dir
	projectile.lifetime = slash_duration
	projectile.size = slash_size
	projectile.damage = slash_damage
	# flip projectile vertically according to slash_direction
	projectile.scale.y = abs(projectile.scale.y) * slash_direction * -1
	get_tree().current_scene.add_child(projectile)

func _process(delta):
	if not slash_active and slash_progress <= 0:
		slash_rotation = 0.0
		return

	if slash_active:
		slash_progress = min(slash_progress + delta / slash_duration, 1)
	else:
		slash_progress = max(slash_progress - delta / slash_duration, 0)

	slash_rotation = slash_direction * slash_angle * sin(slash_progress * PI)

func _start_slash_timers() -> void:
	var anim_timer = get_tree().create_timer(slash_duration)
	anim_timer.timeout.connect(_on_slash_animation_finished)

	var cooldown_timer = get_tree().create_timer(slash_cooldown)
	cooldown_timer.timeout.connect(_on_slash_cooldown_finished)

func _on_slash_animation_finished() -> void:
	slash_active = false
	slash_direction *= -1
	slash_rotation = 0.0

func _on_slash_cooldown_finished() -> void:
	can_slash = true
