extends Control

@export var player_path: NodePath

signal inventory_toggle_requested
signal inventory_exit_requested
signal stats_toggle_requested

@onready var health_label: Label = $HealthUI/HealthLabel
@onready var health_bar: ProgressBar = $HealthUI/HealthBar
@onready var inventory_button: Button = $InventoryButton/Button
@onready var stats_button: Button = $StatsButton/Button

@onready var last_hit_enemy_ui: Control = $LastHitEnemyUI
@onready var enemy_health_bar: ProgressBar = $LastHitEnemyUI/EnemyHealthBar
@onready var enemy_name_label: Label = $LastHitEnemyUI/VBoxContainer/EnemyNameLabel
@onready var enemy_health_label: Label = $LastHitEnemyUI/VBoxContainer/EnemyHealthLabel

var tracked_enemy: Node = null
var tracked_enemy_health: HealthComponent = null

var player: Node = null
var health: HealthComponent = null


func _ready() -> void:
	_find_player()
	_connect_last_hit_signal()
	_connect_health()
	_refresh_health_display()

	last_hit_enemy_ui.visible = false

	inventory_button.pressed.connect(_on_inventory_button_pressed)
	stats_button.pressed.connect(_on_stats_button_pressed)


func _find_player() -> void:
	if player_path != NodePath():
		player = get_node_or_null(player_path)
	else:
		player = get_tree().get_first_node_in_group("player")


func _connect_last_hit_signal() -> void:
	if player == null:
		return

	if not player.has_signal("last_enemy_hit"):
		push_warning("HUD could not find player signal 'last_enemy_hit'.")
		return

	if not player.last_enemy_hit.is_connected(_on_last_enemy_hit):
		player.last_enemy_hit.connect(_on_last_enemy_hit)


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


func _on_last_enemy_hit(target: Node, health_component: HealthComponent) -> void:
	if tracked_enemy == target and tracked_enemy_health == health_component:
		_update_tracked_enemy_display(health_component.current_health, health_component.max_health)
		return

	_clear_tracked_enemy_connections()

	tracked_enemy = target
	tracked_enemy_health = health_component

	if tracked_enemy_health == null:
		last_hit_enemy_ui.visible = false
		return

	if not tracked_enemy_health.health_changed.is_connected(_on_tracked_enemy_health_changed):
		tracked_enemy_health.health_changed.connect(_on_tracked_enemy_health_changed)

	if not tracked_enemy_health.died.is_connected(_on_tracked_enemy_died):
		tracked_enemy_health.died.connect(_on_tracked_enemy_died)

	_update_tracked_enemy_display(tracked_enemy_health.current_health, tracked_enemy_health.max_health)


func _on_tracked_enemy_health_changed(current: int, max_health: int) -> void:
	_update_tracked_enemy_display(current, max_health)


func _on_tracked_enemy_died(_source: Node) -> void:
	_clear_tracked_enemy_connections()
	tracked_enemy = null
	tracked_enemy_health = null
	last_hit_enemy_ui.visible = false
	enemy_name_label.text = ""
	enemy_health_label.text = ""


func _clear_tracked_enemy_connections() -> void:
	if tracked_enemy_health == null:
		return

	if tracked_enemy_health.health_changed.is_connected(_on_tracked_enemy_health_changed):
		tracked_enemy_health.health_changed.disconnect(_on_tracked_enemy_health_changed)

	if tracked_enemy_health.died.is_connected(_on_tracked_enemy_died):
		tracked_enemy_health.died.disconnect(_on_tracked_enemy_died)


func _update_tracked_enemy_display(current: int, max_health: int) -> void:
	enemy_health_bar.max_value = max_health
	enemy_health_bar.value = current
	enemy_health_label.text = "%d / %d" % [current, max_health]

	if tracked_enemy != null:
		enemy_name_label.text = _get_enemy_display_name(tracked_enemy)
	else:
		enemy_name_label.text = ""

	last_hit_enemy_ui.visible = current > 0


func _get_enemy_display_name(enemy: Node) -> String:
	if enemy == null:
		return ""

	if "display_name" in enemy:
		return String(enemy.display_name)

	return enemy.name


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory_toggle"):
		if UIState.block_game_input:
			return
		inventory_toggle_requested.emit()

	if event.is_action_pressed("stats_toggle"):
		if UIState.block_game_input:
			return
		stats_toggle_requested.emit()

	if event.is_action_pressed("menu_exit"):
		inventory_exit_requested.emit()


func _on_inventory_button_pressed() -> void:
	inventory_toggle_requested.emit()


func _on_stats_button_pressed() -> void:
	stats_toggle_requested.emit()
