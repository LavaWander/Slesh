extends Node
class_name PlayerHealthController

@export var health_path: NodePath
@export var stats_path: NodePath

var health: HealthComponent
var stats: StatsComponent


func _ready() -> void:
	if health_path != NodePath():
		health = get_node_or_null(health_path) as HealthComponent

	if stats_path != NodePath():
		stats = get_node_or_null(stats_path) as StatsComponent

	if health == null:
		push_warning("PlayerHealthController could not find HealthComponent.")
		return

	if stats == null:
		push_warning("PlayerHealthController could not find StatsComponent.")
		return

	_recalculate_max_health()

	# if your EquipmentComponent emits equipment_changed and StatsComponent stays query-based,
	# you can listen to equipment directly through stats.equipment
	if stats.equipment != null:
		stats.stats_changed.connect(_on_equipment_changed)


func _on_equipment_changed() -> void:
	_recalculate_max_health()


func _recalculate_max_health() -> void:
	var old_max: int = health.max_health
	var old_current: int = health.current_health

	var new_max := int(stats.calculate_stat(&"max_health"))
	new_max = max(new_max, 1)

	health.max_health = new_max

	# preserve current health proportionally when max health changes
	if old_max > 0:
		var ratio: float = float(old_current) / float(old_max)
		health.current_health = int(round(ratio * new_max))
	else:
		health.current_health = new_max

	health.current_health = clamp(health.current_health, 0, health.max_health)
	health.health_changed.emit(health.current_health, health.max_health)
