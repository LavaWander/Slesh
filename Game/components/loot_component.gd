extends Node
class_name LootComponent

@export var drops: Array[LootDrop] = []

var rng := RandomNumberGenerator.new()

func _ready() -> void:
	rng.randomize()

func drop_to_killer(killer: Node) -> void:
	var inventory := _find_inventory(killer)
	if inventory == null:
		return

	for drop in drops:
		if drop == null or drop.item == null:
			continue

		var chance: float = clampf(drop.chance_percent, 0.0, 100.0)
		if rng.randf_range(0.0, 100.0) > chance:
			continue

		var min_qty: int = maxi(drop.min_quantity, 1)
		var max_qty: int = maxi(drop.max_quantity, min_qty)
		var quantity := rng.randi_range(min_qty, max_qty)

		inventory.add_item(drop.item, quantity)

func _find_inventory(node: Node) -> InventoryComponent:
	if node == null:
		return null

	return node.get_node_or_null("InventoryComponent") as InventoryComponent
