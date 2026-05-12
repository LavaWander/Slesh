extends Resource
class_name PlayerData

## Unified container for all saveable player state.
## To add new saveable data in the future, just add another @export here.
## Examples:
##   @export var player_level: int = 1
##   @export var unlocked_abilities: Array[StringName] = []
##   @export var quest_flags: Dictionary = {}

## --- Position ---
@export var spawn_position: Vector2 = Vector2.ZERO

## --- Health ---
## -1 means "use max health" (fresh save / full heal)
@export var current_health: int = -1

## --- Inventory ---
## Each entry: { "item_id": StringName, "quantity": int }
@export var inventory_items: Array[Dictionary] = []

## --- Equipment ---
## Keys: slot names (e.g. &"chest", &"ring1")
## Values: item_id StringName, or &"" for empty
@export var equipment_slots: Dictionary = {}

## --- Meta ---
@export var save_timestamp: String = ""
@export var play_time_seconds: float = 0.0
