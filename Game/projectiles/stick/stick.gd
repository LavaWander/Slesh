extends Node2D

var config: ProjectileConfig
var direction: Vector2 = Vector2.RIGHT
var elapsed: float = 0.0
var instigator = null
var faction := ""
var hit_bodies: Array = []


func initialize(new_config: ProjectileConfig, pos: Vector2, dir: Vector2, new_instigator = null) -> void:
	config = new_config
	global_position = pos
	direction = dir.normalized()
	instigator = new_instigator
	
	if instigator != null and "faction" in instigator:
		faction = instigator.faction
	
	scale = Vector2.ONE * config.size


func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if config == null:
		return

	elapsed += delta

	position += direction * config.speed * delta
	rotation = direction.angle()

	if elapsed >= config.lifetime:
		queue_free()


func _on_body_entered(body) -> void:
	if body == instigator:
		return

	if "faction" in body and body.faction == faction:
		return  # ignore same team
		
	if body in hit_bodies:
		return

	if body.has_method("take_damage"):
		body.take_damage(config.damage)
		hit_bodies.append(body)

	queue_free()
