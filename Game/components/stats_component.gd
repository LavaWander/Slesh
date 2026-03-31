extends Node
class_name StatsComponent

@export var equipment_path: NodePath

var equipment: EquipmentComponent


func _ready() -> void:
	if equipment_path != NodePath():
		equipment = get_node_or_null(equipment_path) as EquipmentComponent
	
	if equipment == null:
		push_warning("StatsComponent could not find EquipmentComponent.")


func get_add(stat_name: StringName) -> float:
	var total: float = 0.0

	for modifier in _get_all_modifiers():
		if modifier.stat_name == stat_name and modifier.mode == StatModifier.Mode.ADD:
			total += modifier.value

	return total


func get_mult(stat_name: StringName) -> float:
	var total: float = 1.0

	for modifier in _get_all_modifiers():
		if modifier.stat_name == stat_name and modifier.mode == StatModifier.Mode.MULTIPLY:
			total *= modifier.value

	return total


func _get_all_modifiers() -> Array[StatModifier]:
	var result: Array[StatModifier] = []

	if equipment == null:
		return result

	for item in equipment.equipped.values():
		if item == null:
			continue

		for modifier in item.modifiers:
			if modifier != null:
				result.append(modifier)

	return result
