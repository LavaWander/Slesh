extends Control

@export var slot_scene: PackedScene

@onready var background: Panel = $Background
@onready var slots_grid: GridContainer = $Background/SlotsGrid

var player: Node = null
var inventory: InventoryComponent = null


func _ready() -> void:
	visible = false
	_find_player()
	_cache_inventory()


func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")


func _cache_inventory() -> void:
	if player == null:
		push_warning("InventoryPanel could not find player.")
		return

	inventory = player.get_node_or_null("InventoryComponent") as InventoryComponent
	if inventory == null:
		push_warning("InventoryPanel could not find InventoryComponent.")
		return

	if not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	visible = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _on_inventory_changed() -> void:
	if visible:
		_refresh()


func _refresh() -> void:
	if inventory == null or slot_scene == null:
		return

	for child in slots_grid.get_children():
		child.queue_free()

	for slot in inventory.slots:
		var slot_ui = slot_scene.instantiate()
		slots_grid.add_child(slot_ui)
		slot_ui.set_item(slot.item, slot.quantity)
