extends Node2D

@export var projectile_scene: PackedScene

# BASE STATS
@export var thrust_distance_multiplier := 4
@export var thrust_duration := 0.1
@export var thrust_cooldown := 0.5
@export var thrust_size := 1.0
@export var thrust_damage := 1

var can_fire := true
var thrust_progress := 0.0
var thrust_active := false
var base_pos := Vector2.ZERO
var base_dir := Vector2.RIGHT

var thrust_offset := 0.0

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
	
	# get sword distance
	var sword = get_parent()
	var spawn_distance = sword.distance * thrust_distance_multiplier + 25

	# calculate forward spawn position
	var spawn_pos = pos + dir * spawn_distance
	
	
	projectile.position = spawn_pos
	projectile.direction = dir
	projectile.lifetime = thrust_duration
	projectile.size = thrust_size
	projectile.damage = thrust_damage
	get_tree().current_scene.add_child(projectile)

func _process(delta):
	if not thrust_active:
		thrust_offset = 0.0
		return

	thrust_progress = min(thrust_progress + delta / thrust_duration, 1)
	thrust_offset = get_parent().distance * (1 + (thrust_distance_multiplier - 1) * thrust_progress)

func _start_thrust_timers() -> void:
	# animation duration
	var anim_timer = get_tree().create_timer(thrust_duration)
	anim_timer.timeout.connect(_on_thrust_animation_finished)

	# cooldown timer
	var cooldown_timer = get_tree().create_timer(thrust_cooldown)
	cooldown_timer.timeout.connect(_on_thrust_cooldown_finished)

func _on_thrust_animation_finished() -> void:
	thrust_active = false
	thrust_progress = 0.0
	thrust_offset = 0.0

func _on_thrust_cooldown_finished() -> void:
	can_fire = true
