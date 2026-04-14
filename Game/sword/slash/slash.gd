extends Node2D

var direction := Vector2.RIGHT
var hit_enemies := []

var instigator: Node = null
var faction := ""

var speed := 0
var lifetime := 1.0
var size := 1.0
var damage := 1

var elapsed := 0.0

@onready var attack: AttackComponent = $AttackComponent

func _ready():
	# SCALE EVERYTHING (visual + hitbox)
	scale *= Vector2(size, size)

	# adjust animation speed to match lifetime
	var sprite = $AnimatedSprite2D
	var frame_count = sprite.sprite_frames.get_frame_count("default")

	print("Lifetime = ", lifetime)
	print("Frames = ", frame_count)

	sprite.speed_scale = frame_count / lifetime
	sprite.play("default")
	
	attack.configure(damage, instigator, faction)
	
	if not attack.hit_landed.is_connected(_on_hit_landed):
		attack.hit_landed.connect(_on_hit_landed)

	$Area2D.body_entered.connect(_on_body_entered)

func _process(delta):
	elapsed += delta

	position += direction * speed * delta
	rotation = direction.angle()

	if elapsed >= lifetime:
		queue_free()

func _on_body_entered(body):
	attack.try_hit(body)

func _on_hit_landed(target: Node, health: HealthComponent, instigator: Node) -> void:
	if instigator != null and instigator.has_method("register_hit_target"):
		instigator.register_hit_target(target, health, instigator)
