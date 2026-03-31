extends Node
class_name AttackComponent

@export var damage: int = 1
@export var destroy_projectile_on_hit: bool = true
@export var hit_once_per_target: bool = true

var instigator: Node = null
var faction: String = ""
var hit_targets: Array[Node] = []


func configure(new_damage: int, new_instigator: Node = null, new_faction: String = "") -> void:
	damage = new_damage
	instigator = new_instigator
	faction = new_faction
	hit_targets.clear()


func try_hit(target: Node) -> void:
	if target == null:
		return

	if target == instigator:
		return

	if hit_once_per_target and target in hit_targets:
		return

	var target_faction = target.get("faction")
	if faction != "" and target_faction != null and String(target_faction) == faction:
		return

	var health := _find_health_component(target)
	if health == null:
		return

	health.take_damage(damage, instigator)

	if hit_once_per_target:
		hit_targets.append(target)

	if destroy_projectile_on_hit and get_parent():
		get_parent().queue_free()


func _find_health_component(target: Node) -> HealthComponent:
	for child in target.get_children():
		if child is HealthComponent:
			return child

	return null
