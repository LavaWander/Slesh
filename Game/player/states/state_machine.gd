extends Node
class_name PlayerStateMachine

## Layered state machine.
## Child PlayerState nodes are auto-discovered and grouped by their layer.
## Each layer runs one active state at a time.
## States across different layers run concurrently.

# { layer_name: { "current": PlayerState or null, "states": { node_name: PlayerState } } }
var layers: Dictionary = {}
var player: CharacterBody2D


func _ready() -> void:
	player = get_parent() as CharacterBody2D
	if player == null:
		push_warning("PlayerStateMachine must be a child of a CharacterBody2D.")
		return

	# Auto-discover all child PlayerState nodes and group by layer
	for child in get_children():
		if child is PlayerState:
			_register_state(child)

	# Activate each layer's initial state
	for layer_name: StringName in layers:
		var layer_data: Dictionary = layers[layer_name]
		for state: PlayerState in layer_data["states"].values():
			if state.is_initial:
				layer_data["current"] = state
				state.enter()
				break

		if layer_data["current"] == null:
			push_warning("Layer '%s' has no initial state." % layer_name)


func _register_state(state: PlayerState) -> void:
	state.player = player
	state.state_machine = self

	var layer_name: StringName = state.layer
	if not layers.has(layer_name):
		layers[layer_name] = {"current": null, "states": {}}

	layers[layer_name]["states"][StringName(state.name)] = state


## Transition to a state by node name. The state machine finds which layer
## it belongs to and performs the transition within that layer.
func transition_to(state_name: StringName) -> void:
	for layer_name: StringName in layers:
		var layer_data: Dictionary = layers[layer_name]
		if layer_data["states"].has(state_name):
			var old_state: PlayerState = layer_data["current"]
			var new_state: PlayerState = layer_data["states"][state_name]
			if old_state == new_state:
				return

			if old_state != null:
				old_state.exit()

			layer_data["current"] = new_state
			new_state.enter()
			return

	push_warning("PlayerStateMachine: no state named '%s' found." % state_name)


## Get the currently active state in a given layer.
func get_current_state(layer_name: StringName) -> PlayerState:
	if layers.has(layer_name):
		return layers[layer_name]["current"]
	return null


## Check if a state (by node name) is currently active in any layer.
func is_in_state(state_name: StringName) -> bool:
	for layer_name: StringName in layers:
		var current: PlayerState = layers[layer_name]["current"]
		if current != null and current.name == state_name:
			return true
	return false


## Returns the blocking layer name, or &"" if nothing is blocking.
func _get_blocking_layer() -> StringName:
	for layer_name: StringName in layers:
		var current: PlayerState = layers[layer_name]["current"]
		if current != null and current.blocks_other_layers:
			return layer_name
	return &""


func _physics_process(delta: float) -> void:
	var blocking_layer: StringName = _get_blocking_layer()

	for layer_name: StringName in layers:
		var current: PlayerState = layers[layer_name]["current"]
		if current == null:
			continue
		if blocking_layer != &"" and layer_name != blocking_layer:
			continue
		current.physics_update(delta)


func _process(delta: float) -> void:
	var blocking_layer: StringName = _get_blocking_layer()

	for layer_name: StringName in layers:
		var current: PlayerState = layers[layer_name]["current"]
		if current == null:
			continue
		if blocking_layer != &"" and layer_name != blocking_layer:
			continue
		current.process_update(delta)


func _input(event: InputEvent) -> void:
	var blocking_layer: StringName = _get_blocking_layer()

	for layer_name: StringName in layers:
		var current: PlayerState = layers[layer_name]["current"]
		if current == null:
			continue
		if blocking_layer != &"" and layer_name != blocking_layer:
			continue
		current.handle_input(event)
