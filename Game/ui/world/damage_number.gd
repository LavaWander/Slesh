extends Label
class_name DamageNumber

var lifetime: float = 0.35
var elapsed: float = 0.0
var velocity: Vector2 = Vector2.ZERO
var deceleration: float = 0.0

func setup(amount: int, new_lifetime: float, rise_distance: float) -> void:
	text = str(amount)
	reset_size()

	lifetime = maxf(new_lifetime, 0.001)
	elapsed = 0.0

	var initial_up_speed := (2.0 * rise_distance) / lifetime
	velocity = Vector2(0.0, -initial_up_speed)
	deceleration = initial_up_speed / lifetime

func _process(delta: float) -> void:
	elapsed += delta
	position += velocity * delta
	velocity.y = minf(velocity.y + deceleration * delta, 0.0)

	if elapsed >= lifetime:
		queue_free()
