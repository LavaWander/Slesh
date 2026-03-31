extends Node
class_name EquipmentComponent

signal equipment_changed
signal item_equipped(slot_name: StringName, item: ItemData)
signal item_unequipped(slot_name: StringName, item: ItemData)

var equipped: Dictionary = {
	&"head": null,
	&"chest": null,
	&"legs": null,
	&"ring1": null,
	&"ring2": null,
	&"amulet": null,
	&"cape": null
}


func get_item(slot_name: StringName) -> ItemData:
	if equipped.has(slot_name):
		return equipped[slot_name]
	return null


func is_slot_valid(slot_name: StringName) -> bool:
	return equipped.has(slot_name)


func can_equip(item: ItemData) -> bool:
	if item == null:
		return false

	if item.equip_slot == StringName():
		return false

	return is_slot_valid(item.equip_slot)


func equip(item: ItemData) -> bool:
	if not can_equip(item):
		return false

	var slot_name: StringName = item.equip_slot
	var currently_equipped: ItemData = equipped[slot_name]

	if currently_equipped == item:
		return true

	if currently_equipped != null:
		item_unequipped.emit(slot_name, currently_equipped)

	equipped[slot_name] = item
	item_equipped.emit(slot_name, item)
	equipment_changed.emit()
	return true


func unequip(slot_name: StringName) -> ItemData:
	if not is_slot_valid(slot_name):
		return null

	var item: ItemData = equipped[slot_name]
	if item == null:
		return null

	equipped[slot_name] = null
	item_unequipped.emit(slot_name, item)
	equipment_changed.emit()
	return item
