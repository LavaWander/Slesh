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

var slot_types: Dictionary = { # defines what type of item goes into each slot
	&"head": &"head",
	&"chest": &"chest",
	&"legs": &"legs",
	&"ring1": &"ring",
	&"ring2": &"ring",
	&"amulet": &"amulet",
	&"cape": &"cape"
}

func get_item(slot_name: StringName) -> ItemData:
	if equipped.has(slot_name):
		return equipped[slot_name]
	return null


func is_slot_valid(slot_name: StringName) -> bool:
	return equipped.has(slot_name)


func find_first_empty_compatible_slot(item: ItemData) -> StringName:
	for slot_name in equipped.keys():
		if equipped[slot_name] == null and can_equip_in_slot(item, slot_name):
			return slot_name

	return &""


func can_equip(item: ItemData) -> bool:
	return find_first_empty_compatible_slot(item) != StringName()


func equip(item: ItemData) -> bool:
	if item == null:
		return false

	if item.equip_type == StringName():
		return false

	if is_item_equipped(item):
		return false

	var compatible_slots := get_compatible_slots(item.equip_type)
	if compatible_slots.is_empty():
		return false

	for slot_name in compatible_slots:
		if can_equip_in_slot(item, slot_name) and equipped[slot_name] == null:
			equipped[slot_name] = item
			item_equipped.emit(slot_name, item)
			equipment_changed.emit()
			return true

	if compatible_slots.size() == 1:
		var slot_name := compatible_slots[0]
		var currently_equipped: ItemData = equipped[slot_name]

		if currently_equipped != null:
			item_unequipped.emit(slot_name, currently_equipped)

		equipped[slot_name] = item
		item_equipped.emit(slot_name, item)
		equipment_changed.emit()
		return true

	return false


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


func get_slot_type(slot_name: StringName) -> StringName:
	if slot_types.has(slot_name):
		return slot_types[slot_name]
	return &""


func is_item_equipped(item: ItemData) -> bool:
	if item == null:
		return false

	for equipped_item in equipped.values():
		if equipped_item == item:
			return true

	return false


func can_equip_in_slot(item: ItemData, slot_name: StringName) -> bool:
	if item == null:
		return false

	if not is_slot_valid(slot_name):
		return false

	if item.equip_type == StringName():
		return false

	if get_slot_type(slot_name) != item.equip_type:
		return false

	if is_item_equipped(item):
		return false

	return true


func get_first_equipped_item_for_type(equip_type: StringName, excluded_item: ItemData = null) -> ItemData:
	for slot_name in equipped.keys():
		if get_slot_type(slot_name) != equip_type:
			continue

		var equipped_item: ItemData = equipped[slot_name]
		if equipped_item != null and equipped_item != excluded_item:
			return equipped_item

	return null


func get_compatible_slots(equip_type: StringName) -> Array[StringName]:
	var result: Array[StringName] = []

	for slot_name in slot_types.keys():
		if slot_types[slot_name] == equip_type:
			result.append(slot_name)

	return result


func has_multiple_slots_for_type(equip_type: StringName) -> bool:
	return get_compatible_slots(equip_type).size() > 1
