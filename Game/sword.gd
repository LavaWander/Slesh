extends Node2D

@export var distance := 20  # distance from player pivot
@export var rotation_offset := deg_to_rad(90)  # rotate 90 degrees if needed

@export var thrust_distance_multiplier := 4
@export var thrust_duration := 0.1            # seconds
@export var thrust_cooldown := 0.5            # seconds

@export var slash_angle := deg_to_rad(150)      # maximum rotation from base
@export var slash_duration := 0.1              # seconds
@export var slash_cooldown := 0.7

var player: Node2D = null

# internal state
var current_distance := distance
var can_thrust := true
var can_slash := true
var slash_direction := 1  # 1 = right, -1 = left

# dynamic state
var thrust_progress := 0.0   # 0 = base, 1 = full thrust
var slash_progress := 0.0    # 0 = base, 1 = full slash
var thrust_active := false
var slash_active := false

func _process(delta):
	if not player:
		return

	global_position = player.global_position

	var dir = (get_global_mouse_position() - global_position).normalized()
	var base_rotation = dir.angle() + rotation_offset

	# handle thrust smoothing
	if thrust_active:
		thrust_progress = min(thrust_progress + delta / thrust_duration, 1)
	else:
		thrust_progress = max(thrust_progress - delta / thrust_duration, 0)
	var thrust_offset = distance * (1 + (thrust_distance_multiplier - 1) * thrust_progress)

	# handle slash smoothing
	if slash_active:
		slash_progress = min(slash_progress + delta / slash_duration, 1)
	else:
		slash_progress = max(slash_progress - delta / slash_duration, 0)
	var slash_rot = slash_direction * slash_angle * sin(slash_progress * PI)  # smooth swing

	# apply final position and rotation
	$AnimatedSprite2D.global_position = global_position + dir * thrust_offset
	$AnimatedSprite2D.rotation = base_rotation + slash_rot
	
func _input(event):
	if event.is_action_pressed("attack_thrust") and can_thrust:
		start_thrust()
	elif event.is_action_pressed("attack_slash") and can_slash:
		start_slash()

func start_thrust() -> void:
	if can_thrust:
		can_thrust = false
		thrust_active = true
		# smooth thrust duration
		_task_thrust()  # call async function

func start_slash() -> void:
	if can_slash:
		can_slash = false
		slash_active = true
		_task_slash()  # call async function

# async helpers
func _task_thrust() -> void:
	await get_tree().create_timer(thrust_duration).timeout
	thrust_active = false
	await get_tree().create_timer(thrust_cooldown).timeout
	can_thrust = true

func _task_slash() -> void:
	await get_tree().create_timer(slash_duration).timeout
	slash_active = false
	slash_direction *= -1
	await get_tree().create_timer(slash_cooldown).timeout
	can_slash = true
