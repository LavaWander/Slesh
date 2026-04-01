extends Control

@export var slot_scene: PackedScene

@onready var background: Panel = $Background
@onready var title_label: Label = $Background/TitleLabel
@onready var search_box: LineEdit = $Background/SearchBox
@onready var slots_scroll: ScrollContainer = $Background/SlotsScroll
@onready var slots_grid: GridContainer = $Background/SlotsScroll/SlotsGrid

var player: Node = null
var inventory: InventoryComponent = null
var search_text: String = ""


func _ready() -> void:
	visible = false
	_find_player()
	_cache_inventory()

	# Let clicks pass through the full-screen root,
	# but let the actual inventory window handle clicks.
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	background.mouse_filter = Control.MOUSE_FILTER_STOP

	search_box.text_changed.connect(_on_search_text_changed)
	search_box.focus_entered.connect(_on_search_focus_entered)
	search_box.focus_exited.connect(_on_search_focus_exited)


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
	print("blocked")


func _on_search_focus_exited() -> void:
	UIState.block_game_input = false
	print("released")


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
	search_box.release_focus()
	UIState.block_game_input = false


func toggle() -> void:
	if visible:
		close()
	else:
		open()


func _on_inventory_changed() -> void:
	if visible:
		_refresh()


func _on_search_text_changed(new_text: String) -> void:
	search_text = new_text.strip_edges().to_lower()
	if visible:
		_refresh()


func _refresh() -> void:
	if inventory == null or slot_scene == null:
		return

	for child in slots_grid.get_children():
		child.queue_free()

	for slot in inventory.slots:
		if not _slot_matches_search(slot):
			continue

		var slot_ui = slot_scene.instantiate()
		slots_grid.add_child(slot_ui)
		slot_ui.set_item(slot.item, slot.quantity)


func _slot_matches_search(slot: InventorySlot) -> bool:
	if search_text == "":
		return true

	if slot.item == null:
		return false

	var item_name := slot.item.display_name.to_lower()
	return item_name.contains(search_text)
