extends PlayerState

## Alive state — default condition. Listens for death.


func enter() -> void:
	var health: HealthComponent = player.get_node_or_null("HealthComponent")
	if health != null and not health.died.is_connected(_on_player_died):
		health.died.connect(_on_player_died)


func exit() -> void:
	var health: HealthComponent = player.get_node_or_null("HealthComponent")
	if health != null and health.died.is_connected(_on_player_died):
		health.died.disconnect(_on_player_died)


func _on_player_died(_source: Node) -> void:
	state_machine.transition_to(&"Dead")
