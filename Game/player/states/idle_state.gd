extends PlayerState

## Idle state — player is stationary.
## Plays the "idle" animation and waits for movement input.


func enter() -> void:
	player.velocity = Vector2.ZERO
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.animation = "idle"
	sprite.play()


func physics_update(_delta: float) -> void:
	if UIState.block_game_input:
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction != Vector2.ZERO:
		if Input.is_action_pressed("run"):
			state_machine.transition_to(&"Run")
		else:
			state_machine.transition_to(&"Walk")
