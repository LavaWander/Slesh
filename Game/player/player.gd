extends CharacterBody2D

@export var base_speed := 200

const DAMAGE_NUMBER_SPAWNER_SCENE := preload("res://ui/world/damage_number_spawner.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://ui/world/damage_number.tscn")

var faction = "player"
var is_dead: bool = false
var spawn_position: Vector2
signal last_enemy_hit(target: Node, health: HealthComponent)

@onready var state_machine: PlayerStateMachine = $StateMachine
@onready var inventory: InventoryComponent = $InventoryComponent
@onready var equipment: EquipmentComponent = $EquipmentComponent
@onready var stats: StatsComponent = $StatsComponent
var starter_items := [
	#&"business_armor",
	&"godot_armor",
	&"ring1",
	&"ring2",
	&"ring3",
]

var starter_items := [
	#&"business_armor",
	&"godot_armor",
	&"ring1",
	&"ring2",
	&"ring3",
]

func _ready():
	for item_id in starter_items:
		var item := ItemDatabase.get_item(item_id)
		if item != null:
			inventory.add_item(item, 1, &"starter", "")

	spawn_position = global_position
	_spawn_world_ui()
	add_to_group("player")


func register_hit_target(target: Node, health: HealthComponent, instigator: Node) -> void:
	if instigator != self:
		return

	last_enemy_hit.emit(target, health)


func _spawn_world_ui() -> void:
	var damage_number_spawner := DAMAGE_NUMBER_SPAWNER_SCENE.instantiate() as DamageNumberSpawner
	damage_number_spawner.health_path = ^"../HealthComponent"
	damage_number_spawner.collision_shape_path = ^"../Hitbox"
	damage_number_spawner.damage_number_scene = DAMAGE_NUMBER_SCENE
	add_child(damage_number_spawner)
