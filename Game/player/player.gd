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
@onready var health_component: HealthComponent = $HealthComponent

var starter_items := [
	#&"business_armor",
	&"godot_armor",
	&"ring1",
	&"ring2",
	&"ring3",
]

func _ready():
	spawn_position = global_position
	_spawn_world_ui()
	add_to_group("player")

	# Determine whether to load saved data or start fresh
	if SaveManager.data != null and SaveManager.active_slot >= 0:
		if SaveManager.data.inventory_items.size() > 0 or SaveManager.data.equipment_slots.size() > 0:
			# Existing save — load state
			load_state()
		else:
			# New game — give starter items, then save immediately
			_give_starter_items()
			save_state()
			SaveManager.save_game()
	else:
		# Fallback (no SaveManager context) — just give starter items
		_give_starter_items()

	# Wire up auto-save on data changes
	inventory.inventory_changed.connect(_on_data_changed)
	equipment.equipment_changed.connect(_on_data_changed)

	# Start the gameplay session (auto-save timer, play time tracking)
	SaveManager.start_session()


func _give_starter_items() -> void:
	for item_id in starter_items:
		var item := ItemDatabase.get_item(item_id)
		if item != null:
			inventory.add_item(item, 1, &"starter", "")


func save_state() -> void:
	if SaveManager.data == null:
		return

	SaveManager.data.spawn_position = global_position
	inventory.save_to(SaveManager.data)
	equipment.save_to(SaveManager.data)
	health_component.save_to(SaveManager.data)


func load_state() -> void:
	if SaveManager.data == null:
		return

	SaveManager.is_loading = true

	# Position
	spawn_position = SaveManager.data.spawn_position
	global_position = spawn_position

	# Components — equipment first so stats recalculate before health load
	equipment.load_from(SaveManager.data)
	inventory.load_from(SaveManager.data)
	health_component.load_from(SaveManager.data)

	# If the player died before saving, heal to full on reload
	if health_component.current_health <= 0:
		health_component.current_health = health_component.max_health
		health_component.health_changed.emit(health_component.current_health, health_component.max_health)

	SaveManager.is_loading = false


func _on_data_changed() -> void:
	SaveManager.on_data_changed()


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
