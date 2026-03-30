extends Node2D

var direction := Vector2.RIGHT
var hit_enemies := []

var speed := 0
var lifetime := 1.0 # default, should be changed by ThrustHandler
var size := 1.0 # default, should be changed by ThrustHandler

var elapsed := 0.0

func _ready():
	# SCALE EVERYTHING (visual + hitbox)
	scale *= Vector2(size, size)
	
	# adjust animation speed to match lifetime
	var sprite = $AnimatedSprite2D
	var frame_count = sprite.sprite_frames.get_frame_count("default")
	print("Lifetime = ", lifetime)
	print("Frames = ", frame_count)
	

	# FPS = frames / lifetime → animation fits exactly
	sprite.speed_scale = frame_count / lifetime
	sprite.play("default")

	$Area2D.body_entered.connect(_on_body_entered)

func _process(delta):
	elapsed += delta

	position += direction * speed * delta
	rotation = direction.angle()

	if elapsed >= lifetime:
		queue_free()

func _on_body_entered(body):
	if body in hit_enemies:
		return

	if body.has_method("take_damage"):
		body.take_damage(1)
		hit_enemies.append(body)
