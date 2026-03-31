extends Resource
class_name InventorySlot

@export var item: ItemData
@export var quantity: int = 0


func is_empty() -> bool:
	return item == null or quantity <= 0


func can_stack_with(other: ItemData) -> bool:
	if item == null or other == null:
		return false
	return item == other and item.max_stack > 1
