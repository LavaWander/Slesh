extends Resource
class_name ItemData

@export var item_id: StringName
@export var display_name: String = ""
@export var icon: Texture2D

# inventory behavior
@export var max_stack: int = 1

# equipment
@export var equip_slot: StringName = &""  # e.g. "ring", "weapon"

# stats
@export var modifiers: Array[StatModifier] = []
