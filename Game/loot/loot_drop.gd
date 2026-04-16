extends Resource
class_name LootDrop

@export var item: ItemData
@export_range(0.0, 100.0, 0.1) var chance_percent: float = 100.0
@export_range(1, 999, 1) var min_quantity: int = 1
@export_range(1, 999, 1) var max_quantity: int = 1
