extends PlayerState

## Walk state — player is moving at base speed.
## Plays the "walk" animation and handles sprite flipping.


func enter() -> void:
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	sprite.animation = "walk"
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

	if Input.is_action_pressed("run"):
		state_machine.transition_to(&"Run")
		return

	player.velocity = direction * player.base_speed
	player.move_and_slide()

	# flip sprite horizontally
	var sprite: AnimatedSprite2D = player.get_node("AnimatedSprite2D")
	if direction.x != 0:
		sprite.flip_h = direction.x < 0
