extends Node
class_name InventoryComponent

signal inventory_changed
signal item_added(item: ItemData, amount: int, source: StringName, enemy_name: String)

@export var max_slots: int = 24

var slots: Array[InventorySlot] = []


func _ready() -> void:
	_ensure_slot_count()


func _ensure_slot_count() -> void:
	while slots.size() < max_slots:
		slots.append(InventorySlot.new())

func add_item(item_data: ItemData, amount: int = 1, source: StringName = &"unknown", enemy_name: String = "") -> bool:
	if item_data == null or amount <= 0:
		return false

	_ensure_slot_count()

	var remaining := amount
	var added_amount := 0

	if item_data.max_stack > 1:
		for slot in slots:
			if slot.item == item_data and slot.quantity < item_data.max_stack:
				var space := item_data.max_stack - slot.quantity
				var to_add: float = minf(space, remaining)
				if to_add <= 0:
					continue

				slot.quantity += to_add
				remaining -= to_add
				added_amount += to_add

				if remaining <= 0:
					break

	if remaining > 0:
		for slot in slots:
			if slot.is_empty():
				slot.item = item_data

				var to_add := 1
				if item_data.max_stack > 1:
					to_add = min(item_data.max_stack, remaining)

				slot.quantity = to_add
				remaining -= to_add
				added_amount += to_add

				if remaining <= 0:
					break

	if added_amount > 0:
		inventory_changed.emit()
		item_added.emit(item_data, added_amount, source, enemy_name)

	return remaining <= 0

func remove_item(item_data: ItemData, amount: int = 1) -> bool:
	if item_data == null or amount <= 0:
		return false

	var remaining: int = amount

	for slot in slots:
		if slot.item == item_data and slot.quantity > 0:
			var to_remove: int = min(slot.quantity, remaining)
			slot.quantity -= to_remove
			remaining -= to_remove

			if slot.quantity <= 0:
				slot.item = null
				slot.quantity = 0

			if remaining <= 0:
				inventory_changed.emit()
				return true

	inventory_changed.emit()
	return false


func has_item(item_data: ItemData, amount: int = 1) -> bool:
	if item_data == null or amount <= 0:
		return false

	var total: int = 0

	for slot in slots:
		if slot.item == item_data:
			total += slot.quantity
			if total >= amount:
				return true

	return false


func get_item_count(item_data: ItemData) -> int:
	if item_data == null:
		return 0

	var total: int = 0
	for slot in slots:
		if slot.item == item_data:
			total += slot.quantity

	return total
