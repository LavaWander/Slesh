extends Control

@export var player_path: NodePath

signal inventory_toggle_requested
signal inventory_exit_requested

const LOOT_NOTIFICATION_SCENE := preload("res://ui/common/loot_notification.tscn")

@onready var health_label: Label = $HealthUI/HealthLabel
@onready var health_bar: ProgressBar = $HealthUI/HealthBar
@onready var inventory_button: Button = $InventoryButton/Button
<<<<<<< Updated upstream
=======
@onready var stats_button: Button = $StatsButton/Button

@onready var last_hit_enemy_ui: Control = $LastHitEnemyUI
@onready var enemy_health_bar: ProgressBar = $LastHitEnemyUI/EnemyHealthBar
@onready var enemy_name_label: Label = $LastHitEnemyUI/VBoxContainer/EnemyNameLabel
@onready var enemy_health_label: Label = $LastHitEnemyUI/VBoxContainer/EnemyHealthLabel

@onready var loot_notifications: VBoxContainer = $LootNotifications

var tracked_enemy: Node = null
var tracked_enemy_health: HealthComponent = null
>>>>>>> Stashed changes

var player: Node = null
var health: HealthComponent = null

var inventory: InventoryComponent = null


func _ready() -> void:
	_find_player()
	_connect_health()
	_connect_inventory()
	_refresh_health_display()
	
	inventory_button.pressed.connect(_on_inventory_button_pressed)


func _find_player() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)
	else:
		player = get_tree().get_first_node_in_group("player")


func _connect_health() -> void:
	if player == null:
		push_warning("HUD could not find player.")
		return

	health = player.get_node_or_null("HealthComponent") as HealthComponent
	if health == null:
		push_warning("HUD could not find player's HealthComponent.")
		return

	if not health.health_changed.is_connected(_on_health_changed):
		health.health_changed.connect(_on_health_changed)


func _connect_inventory() -> void:
	if player == null:
		return

	inventory = player.get_node_or_null("InventoryComponent") as InventoryComponent
	if inventory == null:
		push_warning("HUD could not find player's InventoryComponent.")
		return

	if not inventory.item_added.is_connected(_on_item_added):
		inventory.item_added.connect(_on_item_added)


func _on_health_changed(current: int, max_health: int) -> void:
	_update_health_display(current, max_health)


func _refresh_health_display() -> void:
	if health == null:
		return

	_update_health_display(health.current_health, health.max_health)


func _update_health_display(current: int, max_health: int) -> void:
	health_bar.max_value = max_health
	health_bar.value = current
	health_label.text = "HP: %d / %d" % [current, max_health]


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		if UIState.block_game_input:
			return
		inventory_toggle_requested.emit()
	
	if event.is_action_pressed("menu_exit"):
		inventory_exit_requested.emit()


func _on_inventory_button_pressed() -> void:
	inventory_toggle_requested.emit()
<<<<<<< Updated upstream
=======


func _on_stats_button_pressed() -> void:
	stats_toggle_requested.emit()


func _on_item_added(item: ItemData, amount: int, source: StringName, enemy_name: String) -> void:
	if source != &"loot":
		return

	var notification := LOOT_NOTIFICATION_SCENE.instantiate() as LootNotification
	loot_notifications.add_child(notification)
	notification.show_notification(enemy_name, item, amount)
>>>>>>> Stashed changes
