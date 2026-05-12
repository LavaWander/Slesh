extends Control

const SLOT_SELECTOR_SCENE := preload("res://ui/main_menu/slot_selector.tscn")

@onready var main_panel: PanelContainer = $Panel
@onready var continue_button: Button = $Panel/VBoxContainer/ContinueButton
@onready var new_game_button: Button = $Panel/VBoxContainer/NewGameButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

var slot_selector: Control = null
var _pending_mode: int = -1  # 0 = new game, 1 = continue


func _ready() -> void:
	continue_button.pressed.connect(_on_continue_pressed)
	new_game_button.pressed.connect(_on_new_game_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	_update_continue_button()
	continue_button.grab_focus()


func _update_continue_button() -> void:
	# Show Continue only if at least one save slot is occupied
	var has_saves := false
	for i in range(SaveManager.MAX_SLOTS):
		if SaveManager.is_slot_occupied(i):
			has_saves = true
			break

	continue_button.visible = has_saves

	if has_saves:
		continue_button.grab_focus()
	else:
		new_game_button.grab_focus()


func _on_continue_pressed() -> void:
	_open_slot_selector(1)  # MODE_CONTINUE


func _on_new_game_pressed() -> void:
	_open_slot_selector(0)  # MODE_NEW_GAME


func _open_slot_selector(mode: int) -> void:
	_pending_mode = mode

	if slot_selector != null:
		slot_selector.queue_free()
		slot_selector = null

	slot_selector = SLOT_SELECTOR_SCENE.instantiate()
	add_child(slot_selector)

	slot_selector.slot_chosen.connect(_on_slot_chosen)
	slot_selector.back_requested.connect(_on_slot_selector_back)

	# Hide the main buttons while selector is open
	main_panel.visible = false

	if mode == 0:
		slot_selector.show_selector(slot_selector.Mode.MODE_NEW_GAME)
	else:
		slot_selector.show_selector(slot_selector.Mode.MODE_CONTINUE)


func _on_slot_chosen(slot_index: int) -> void:
	if _pending_mode == 0:
		# New Game
		SaveManager.new_game(slot_index)
	else:
		# Continue
		SaveManager.load_game(slot_index)

	# Clean up and start the game
	if slot_selector != null:
		slot_selector.queue_free()
		slot_selector = null

	get_tree().change_scene_to_file("res://main.tscn")


func _on_slot_selector_back() -> void:
	if slot_selector != null:
		slot_selector.queue_free()
		slot_selector = null

	main_panel.visible = true
	_update_continue_button()


func _on_settings_pressed() -> void:
	print("Settings menu stub.")


func _on_quit_pressed() -> void:
	get_tree().quit()
