extends Node2D

signal thrust_fired(pos, dir)
signal slash_fired(pos, dir)

# sword position settings
@export var distance := 20  # distance from player pivot
@export var rotation_offset := deg_to_rad(90)  # rotate 90 degrees if needed

var player: Node2D = null

func _ready():
	connect("thrust_fired", $ThrustHandler._on_thrust_fired)
	connect("slash_fired", $SlashHandler._on_slash_fired)

func _process(delta):
	if not player:
		return

	global_position = player.global_position

	var dir = (get_global_mouse_position() - global_position).normalized()
	var base_rotation = dir.angle() + rotation_offset

	var thrust_offset = $ThrustHandler.thrust_offset
	var slash_rot = $SlashHandler.slash_rotation

	var final_distance = thrust_offset if thrust_offset > 0 else distance

	$AnimatedSprite2D.global_position = global_position + dir * final_distance
	$AnimatedSprite2D.rotation = base_rotation + slash_rot
	
func _input(event):
	if event.is_action_pressed("attack_thrust"):
		emit_signal("thrust_fired", global_position, (get_global_mouse_position() - global_position).normalized())
	elif event.is_action_pressed("attack_slash"):
		emit_signal("slash_fired", $AnimatedSprite2D.global_position, (get_global_mouse_position() - global_position).normalized())
