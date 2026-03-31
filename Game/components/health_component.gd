extends Node
class_name HealthComponent

signal health_changed(current: int, max_health: int)
signal damaged(amount: int, current: int, source: Node)
signal died(source: Node)

@export var max_health: int = 10
@export var destroy_owner_on_death: bool = false

var current_health: int


func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health, max_health)


func take_damage(amount: int, source: Node = null) -> void:
	if amount <= 0:
		return

	current_health = max(current_health - amount, 0)

	emit_signal("damaged", amount, current_health, source)
	emit_signal("health_changed", current_health, max_health)

	if current_health == 0:
		emit_signal("died", source)

		if destroy_owner_on_death and get_parent():
			get_parent().queue_free()


func heal(amount: int) -> void:
	if amount <= 0:
		return

	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health, max_health)


func is_low(threshold: float = 0.2) -> bool:
	return current_health <= int(max_health * threshold)
