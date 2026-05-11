extends Node
class_name PlayerState

## Which layer this state belongs to.
## States in the same layer are mutually exclusive.
## States in different layers run concurrently.
@export var layer: StringName = &"default"

## Mark exactly one state per layer as the initial state.
@export var is_initial: bool = false

## If true, all states in OTHER layers are paused while this state is active.
@export var blocks_other_layers: bool = false

var player: CharacterBody2D
var state_machine: Node  # PlayerStateMachine


## Called when this state becomes the active state in its layer.
func enter() -> void:
	pass


## Called when this state is replaced by another state in the same layer.
func exit() -> void:
	pass


## Called every physics frame while this state is active.
func physics_update(delta: float) -> void:
	pass


## Called every frame while this state is active.
func process_update(_delta: float) -> void:
	pass


## Called for unhandled input while this state is active.
func handle_input(_event: InputEvent) -> void:
	pass
