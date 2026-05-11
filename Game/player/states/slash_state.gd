extends PlayerState

## Slash attack state — handles slash input.
## Lives in its own layer so it runs concurrently with movement and thrust.
## When Dead blocks other layers, this state's handle_input is never called.


func handle_input(event: InputEvent) -> void:
	if UIState.block_game_input:
		return

	if event.is_action_pressed("attack_slash"):
		var sword: Node2D = player.get_node_or_null("Sword")
		if sword == null:
			return

		var sword_sprite: AnimatedSprite2D = sword.get_node("AnimatedSprite2D")
		var dir := (sword.get_global_mouse_position() - sword.global_position).normalized()
		sword.emit_signal("slash_fired", sword_sprite.global_position, dir)
