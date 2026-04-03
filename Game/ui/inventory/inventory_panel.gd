extends Control

@export var slot_scene: PackedScene
@export var tooltip_scene: PackedScene

@onready var background: Panel = $Background
@onready var title_label: Label = $Background/TitleLabel
@onready var search_box: LineEdit = $Background/SearchBox
@onready var slots_scroll: ScrollContainer = $Background/SlotsScroll
@onready var slots_grid: GridContainer = $Background/SlotsScroll/SlotsGrid
@onready var equipment_panel: Control = $Background/EquipmentPanel
var tooltip: ItemTooltip = null

var player: Node = null
var inventory: InventoryComponent = null
var equipment: EquipmentComponent = null
var search_text: String = ""
var inventory_slot_uis: Array[ItemSlotUI] = []


func _ready() -> void:
	visible = false
	_find_player()
	_cache_components()

	search_box.text_changed.connect(_on_search_text_changed)
	search_box.focus_entered.connect(_on_search_focus_entered)
	search_box.focus_exited.connect(_on_search_focus_exited)
	
	call_deferred("_warm_up_inventory_ui")


func _warm_up_inventory_ui() -> void:
	_ensure_inventory_slot_pool()
	_refresh_inventory()
	_refresh_equipment()


func _input(event: InputEvent) -> void:
	if not visible:
		return

	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if search_box.has_focus():
			var rect: Rect2 = search_box.get_global_rect()
			if not rect.has_point(event.position):
				search_box.release_focus()


func _on_search_focus_entered() -> void:
	UIState.block_game_input = true


func _on_search_focus_exited() -> void:
	UIState.block_game_input = false


func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")


func _cache_components() -> void:
	if player == null:
		push_warning("InventoryPanel could not find player.")
		return

	inventory = player.get_node_or_null("InventoryComponent") as InventoryComponent
	if inventory == null:
		push_warning("InventoryPanel could not find InventoryComponent.")

	equipment = player.get_node_or_null("EquipmentComponent") as EquipmentComponent
	if equipment == null:
		push_warning("InventoryPanel could not find EquipmentComponent.")

	if inventory != null and not inventory.inventory_changed.is_connected(_on_inventory_changed):
		inventory.inventory_changed.connect(_on_inventory_changed)

	if equipment != null and not equipment.equipment_changed.is_connected(_on_equipment_changed):
		equipment.equipment_changed.connect(_on_equipment_changed)


func open() -> void:
	_refresh()
	visible = true


func close() -> void:
	visible = false
	search_box.release_focus()
	_despawn_tooltip()
	UIState.block_game_input = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _on_inventory_changed() -> void:
	if visible:
		_refresh_inventory()


func _on_equipment_changed() -> void:
	if visible:
		_refresh_equipment()


func _on_search_text_changed(new_text: String) -> void:
	search_text = new_text.strip_edges().to_lower()
	if visible:
		_refresh_inventory()


func _refresh() -> void:
	_refresh_inventory()
	_refresh_equipment()


func _refresh_inventory() -> void:
	if inventory == null or slot_scene == null:
		return

	_ensure_inventory_slot_pool()

	for i in range(inventory.slots.size()):
		var slot := inventory.slots[i]
		var slot_ui := inventory_slot_uis[i]

		slot_ui.set_item(slot.item, slot.quantity)
		slot_ui.visible = _slot_matches_search(slot)
		slot_ui.set_equipped_highlight(slot.item != null and _is_item_currently_equipped(slot.item))


func _ensure_inventory_slot_pool() -> void:
	if inventory == null or slot_scene == null:
		return

	if inventory_slot_uis.size() == inventory.slots.size():
		return

	for slot_ui in inventory_slot_uis:
		if is_instance_valid(slot_ui):
			slot_ui.queue_free()

	inventory_slot_uis.clear()

	for i in range(inventory.slots.size()):
		var slot_ui := slot_scene.instantiate() as ItemSlotUI
		slots_grid.add_child(slot_ui)

		slot_ui.clicked.connect(_on_inventory_slot_clicked)
		slot_ui.hovered.connect(_on_inventory_slot_hovered)
		slot_ui.unhovered.connect(_on_slot_unhovered)

		inventory_slot_uis.append(slot_ui)


func _refresh_equipment() -> void:
	if equipment == null:
		return

	for child in equipment_panel.get_children():
		if child is EquipmentSlotUI:
			var slot_ui := child as EquipmentSlotUI
			var equipped_item := equipment.get_item(slot_ui.slot_name)
			slot_ui.set_item(equipped_item)

			if not slot_ui.clicked.is_connected(_on_equipment_slot_clicked):
				slot_ui.clicked.connect(_on_equipment_slot_clicked)

			if not slot_ui.hovered.is_connected(_on_equipment_slot_hovered):
				slot_ui.hovered.connect(_on_equipment_slot_hovered)

			if not slot_ui.unhovered.is_connected(_on_slot_unhovered):
				slot_ui.unhovered.connect(_on_slot_unhovered)


func _slot_matches_search(slot: InventorySlot) -> bool:
	if search_text == "":
		return true

	if slot.item == null:
		return false

	var item_name := slot.item.display_name.to_lower()
	return item_name.contains(search_text)


func _is_item_currently_equipped(item: ItemData) -> bool:
	if equipment == null or item == null:
		return false

	for equipped_item in equipment.equipped.values():
		if equipped_item == item:
			return true

	return false


func _find_equipped_slot_for_item(item: ItemData) -> StringName:
	if equipment == null or item == null:
		return &""

	for slot_name in equipment.equipped.keys():
		if equipment.equipped[slot_name] == item:
			return slot_name

	return &""


func _on_inventory_slot_clicked(item: ItemData) -> void:
	if item == null or equipment == null:
		return

	if item.equip_type == StringName():
		return

	var equipped_slot := _find_equipped_slot_for_item(item)

	# If this exact item is already equipped, clicking it again unequips it
	if equipped_slot != StringName():
		equipment.unequip(equipped_slot)
		_refresh()
		return

	# Otherwise equip it into its defined slot
	equipment.equip(item)
	_refresh()


func _on_equipment_slot_clicked(slot_name: StringName) -> void:
	if equipment == null:
		return

	equipment.unequip(slot_name)
	_refresh()


func _get_equipped_item_for_same_type(item: ItemData) -> ItemData:
	if equipment == null or item == null:
		return null

	if item.equip_type == StringName():
		return null

	if equipment.is_item_equipped(item):
		return null

	if equipment.has_multiple_slots_for_type(item.equip_type):
		return null

	return equipment.get_first_equipped_item_for_type(item.equip_type)


func _on_inventory_slot_hovered(item: ItemData) -> void:
	if item == null:
		return

	var compare_item := _get_equipped_item_for_same_type(item)
	_spawn_tooltip(item, compare_item)


func _on_equipment_slot_hovered(item: ItemData) -> void:
	if item == null:
		return

	_spawn_tooltip(item)


func _on_slot_unhovered() -> void:
	if tooltip != null:
		_despawn_tooltip()


func _spawn_tooltip(item: ItemData, compare_item: ItemData = null) -> void:
	if tooltip_scene == null or item == null:
		return

	_despawn_tooltip()

	tooltip = tooltip_scene.instantiate() as ItemTooltip
	get_parent().add_child(tooltip)
	tooltip.show_tooltip(item, compare_item)


func _despawn_tooltip() -> void:
	if tooltip != null:
		tooltip.queue_free()
		tooltip = null
