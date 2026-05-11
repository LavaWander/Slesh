extends PlayerState

## Thrust attack state — handles thrust input.
## Lives in its own layer so it runs concurrently with movement and slash.
## When Dead blocks other layers, this state's handle_input is never called.


func handle_input(event: InputEvent) -> void:
	if UIState.block_game_input:
		return

	if event.is_action_pressed("attack_thrust"):
		var sword: Node2D = player.get_node_or_null("Sword")
		if sword == null:
			return

		var dir := (sword.get_global_mouse_position() - sword.global_position).normalized()
		sword.emit_signal("thrust_fired", sword.global_position, dir)
