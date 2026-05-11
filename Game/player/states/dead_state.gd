extends PlayerState

## Dead state — blocks all other layers.
## Freezes the player until revive() is called.

signal player_died
signal player_revived


func enter() -> void:
	player.velocity = Vector2.ZERO
	player.is_dead = true

	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.stop()

	# Hide the sword while dead
	var sword: Node2D = player.get_node_or_null("Sword")
	if sword != null:
		sword.visible = false

	player_died.emit()


func exit() -> void:
	player.is_dead = false

	# Show the sword again
	var sword: Node2D = player.get_node_or_null("Sword")
	if sword != null:
		sword.visible = true

	player_revived.emit()


func physics_update(_delta: float) -> void:
	# Ensure the player stays frozen
	player.velocity = Vector2.ZERO


## Call this to bring the player back to life.
## Restores health, transitions condition layer back to Alive,
## and resets movement to Idle.
func revive() -> void:
	# Reset position to spawn
	player.global_position = player.spawn_position

	var health: HealthComponent = player.get_node_or_null("HealthComponent")
	if health != null:
		health.current_health = health.max_health
		health.health_changed.emit(health.current_health, health.max_health)

	state_machine.transition_to(&"Alive")
	state_machine.transition_to(&"Idle")
