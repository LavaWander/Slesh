extends Node2D

signal thrust_fired(pos, dir)
signal slash_fired(pos, dir)

# sword position settings
@export var distance := 20.0
@export var rotation_offset := deg_to_rad(90.0)

@onready var thrust_handler: Node = $ThrustHandler
@onready var slash_handler: Node = $SlashHandler
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var player: Node2D


func _ready() -> void:
	player = get_parent() as Node2D

	connect("thrust_fired", thrust_handler._on_thrust_fired)
	connect("slash_fired", slash_handler._on_slash_fired)

	# pass player stats to handlers if available
	if player != null:
		var stats := player.get_node_or_null("StatsComponent") as StatsComponent
		thrust_handler.stats = stats
		slash_handler.stats = stats


func _process(_delta: float) -> void:
	if player == null:
		return

	# sword root stays at player's local origin
	position = Vector2.ZERO

	var dir := (get_global_mouse_position() - global_position).normalized()
	var base_rotation := dir.angle() + rotation_offset

	var thrust_offset = thrust_handler.thrust_offset
	var slash_rot = slash_handler.slash_rotation

	var final_distance = thrust_offset if thrust_offset > 0.0 else distance

	# because sprite is a child of sword, use local position here
	sprite.position = dir * final_distance
	sprite.rotation = base_rotation + slash_rot


func _input(event: InputEvent) -> void:
	if UIState.block_game_input:
		return

	if player == null:
		return

	var dir := (get_global_mouse_position() - global_position).normalized()

	if event.is_action_pressed("attack_thrust"):
		emit_signal("thrust_fired", global_position, dir)
	elif event.is_action_pressed("attack_slash"):
		emit_signal("slash_fired", sprite.global_position, dir)
