extends PlayerState

## Run state — player is moving at 1.5× base speed.
## Plays the "run" animation and handles sprite flipping.

const RUN_MULTIPLIER := 1.5


func enter() -> void:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.animation = "run"
	sprite.play()


func physics_update(_delta: float) -> void:
	if UIState.block_game_input:
		player.velocity = Vector2.ZERO
		state_machine.transition_to(&"Idle")
		return

	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if direction == Vector2.ZERO:
		state_machine.transition_to(&"Idle")
		return

	if not Input.is_action_pressed("run"):
		state_machine.transition_to(&"Walk")
		return

	player.velocity = direction * player.base_speed * RUN_MULTIPLIER
	player.move_and_slide()

	# flip sprite horizontally
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
