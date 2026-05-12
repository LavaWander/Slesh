extends CanvasLayer

@onready var hud: Control = $HUD
@onready var inventory_panel: Control = $InventoryPanel
@onready var stats_panel: Control = $StatsPanel
@onready var respawn_ui: RespawnUI = $RespawnUI
@onready var pause_menu: Control = $PauseMenu

func _ready() -> void:
	hud.inventory_toggle_requested.connect(_on_inventory_toggle_requested)
	hud.stats_toggle_requested.connect(_on_stats_toggle_requested)
	hud.inventory_exit_requested.connect(_on_inventory_exit_requested)

	respawn_ui.respawn_requested.connect(_on_respawn_requested)
	respawn_ui.main_menu_requested.connect(_on_respawn_main_menu_requested)
	
	pause_menu.resume_requested.connect(_on_pause_resume_requested)
	pause_menu.main_menu_requested.connect(_on_pause_main_menu_requested)

	# Defer player connection so the player node is ready
	_connect_player_death.call_deferred()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_handle_pause_action()

func _handle_pause_action() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player != null and player.is_dead:
		return # Do nothing if dead
		
	if inventory_panel.visible or stats_panel.visible:
		_on_inventory_exit_requested()
		return
		
	if pause_menu.visible:
		pause_menu.hide_menu()
	else:
		pause_menu.show_menu()

func _on_pause_resume_requested() -> void:
	pause_menu.hide_menu()

func _on_pause_main_menu_requested() -> void:
	# pause_menu already unpaused the tree
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


func _connect_player_death() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("UIRoot: could not find player for death UI.")
		return

	var state_machine: PlayerStateMachine = player.get_node_or_null("StateMachine")
	if state_machine == null:
		push_warning("UIRoot: player has no StateMachine.")
		return

	var dead_state := state_machine.get_node_or_null("Dead")
	if dead_state == null:
		push_warning("UIRoot: player StateMachine has no Dead state.")
		return

	dead_state.player_died.connect(_on_player_died)
	dead_state.player_revived.connect(_on_player_revived)


func _on_player_died() -> void:
	# Close any open menus
	inventory_panel.close()
	stats_panel.close()

	respawn_ui.show_screen()


func _on_player_revived() -> void:
	respawn_ui.hide_screen()


func _on_respawn_requested() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		return

	var state_machine: PlayerStateMachine = player.get_node_or_null("StateMachine")
	if state_machine == null:
		return

	var dead_state = state_machine.get_node_or_null("Dead")
	if dead_state != null and dead_state.has_method("revive"):
		dead_state.revive()


func _on_respawn_main_menu_requested() -> void:
	# Unpause just in case, though death doesn't pause the tree
	get_tree().paused = false
	SaveManager.end_session()
	get_tree().change_scene_to_file("res://ui/main_menu/main_menu.tscn")


func _on_inventory_toggle_requested() -> void:
	if inventory_panel.visible:
		inventory_panel.close()
	else:
		stats_panel.close()
		inventory_panel.open()

func _on_stats_toggle_requested() -> void:
	if stats_panel.visible:
		stats_panel.close()
	else:
		inventory_panel.close()
		stats_panel.open()

func _on_inventory_exit_requested() -> void:
	inventory_panel.close()
	stats_panel.close()
