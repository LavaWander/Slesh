extends Node
class_name StatsComponent

signal stats_changed

@export var equipment_path: NodePath

@export_group("Base Stats")
@export var base_max_health := 100.0
@export var base_thrust_damage := 1.0
@export var base_thrust_size := 1.0
@export var base_thrust_duration := 0.1
@export var base_thrust_cooldown := 0.5
@export var base_thrust_distance_multiplier := 4.0
@export var base_slash_damage := 1.0
@export var base_slash_size := 1.0
@export var base_slash_duration := 0.1
@export var base_slash_cooldown := 0.7
@export var base_slash_angle := deg_to_rad(150.0)

const STAT_ORDER: Array[StringName] = [
	&"max_health",
	&"thrust_damage",
	&"thrust_size",
	&"thrust_duration",
	&"thrust_cooldown",
	&"thrust_distance_multiplier",
	&"slash_damage",
	&"slash_size",
	&"slash_duration",
	&"slash_cooldown",
	&"slash_angle",
]

const STAT_META := {
	&"max_health": {"label": "Max Health", "min": 1.0, "round_to_int": true},
	&"thrust_damage": {"label": "Thrust Damage", "min": 1.0, "round_to_int": true},
	&"thrust_size": {"label": "Thrust Size", "min": 0.01, "round_to_int": false},
	&"thrust_duration": {"label": "Thrust Duration", "min": 0.01, "round_to_int": false},
	&"thrust_cooldown": {"label": "Thrust Cooldown", "min": 0.01, "round_to_int": false},
	&"thrust_distance_multiplier": {"label": "Thrust Distance", "min": 0.01, "round_to_int": false},
	&"slash_damage": {"label": "Slash Damage", "min": 1.0, "round_to_int": true},
	&"slash_size": {"label": "Slash Size", "min": 0.01, "round_to_int": false},
	&"slash_duration": {"label": "Slash Duration", "min": 0.01, "round_to_int": false},
	&"slash_cooldown": {"label": "Slash Cooldown", "min": 0.01, "round_to_int": false},
	&"slash_angle": {"label": "Slash Angle", "min": 0.0, "round_to_int": false, "display_as_degrees": true},
}

var equipment: EquipmentComponent


func _ready() -> void:
	if equipment_path != NodePath():
		equipment = get_node_or_null(equipment_path) as EquipmentComponent

	if equipment == null:
		push_warning("StatsComponent could not find EquipmentComponent.")
		return

	if not equipment.equipment_changed.is_connected(_on_equipment_changed):
		equipment.equipment_changed.connect(_on_equipment_changed)

	stats_changed.emit()


func _on_equipment_changed() -> void:
	stats_changed.emit()


func get_add(stat_name: StringName) -> float:
	var total: float = 0.0

	for modifier in _get_all_modifiers():
		if modifier.get_stat_name() == stat_name and modifier.mode == StatModifier.Mode.ADD:
			total += modifier.value

	return total


func get_mult(stat_name: StringName) -> float:
	var total: float = 1.0

	for modifier in _get_all_modifiers():
		if modifier.get_stat_name() == stat_name and modifier.mode == StatModifier.Mode.MULTIPLY:
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


func get_base(stat_name: StringName) -> float:
	match stat_name:
		&"max_health": return base_max_health
		&"thrust_damage": return base_thrust_damage
		&"thrust_size": return base_thrust_size
		&"thrust_duration": return base_thrust_duration
		&"thrust_cooldown": return base_thrust_cooldown
		&"thrust_distance_multiplier": return base_thrust_distance_multiplier
		&"slash_damage": return base_slash_damage
		&"slash_size": return base_slash_size
		&"slash_duration": return base_slash_duration
		&"slash_cooldown": return base_slash_cooldown
		&"slash_angle": return base_slash_angle
		_: return 0.0


func calculate_stat(stat_name: StringName) -> float:
	var base := get_base(stat_name)
	var add := get_add(stat_name)
	var mult := get_mult(stat_name)
	var final_value := (base + add) * mult

	var meta: Dictionary = STAT_META.get(stat_name, {})
	if meta.has("min"):
		final_value = max(final_value, meta["min"])

	if meta.get("round_to_int", false):
		final_value = round(final_value)

	return final_value


func get_breakdown(stat_name: StringName) -> Dictionary:
	var base := get_base(stat_name)
	var add := get_add(stat_name)
	var mult := get_mult(stat_name)
	var final_value := calculate_stat(stat_name)

	return {
		"stat_name": stat_name,
		"label": STAT_META.get(stat_name, {}).get("label", str(stat_name)),
		"base": base,
		"add": add,
		"mult": mult,
		"final": final_value,
	}



func get_all_breakdowns() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for stat_name in STAT_ORDER:
		result.append(get_breakdown(stat_name))

	return result
