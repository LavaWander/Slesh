extends Node

## SaveManager autoload — manages 6 save slots, auto-save, and session lifecycle.
##
## Usage:
##   SaveManager.new_game(slot_index)    → start fresh in a slot
##   SaveManager.load_game(slot_index)   → load existing save
##   SaveManager.save_game()             → persist current state to active slot
##   SaveManager.start_session()         → begin tracking (called on gameplay scene enter)
##   SaveManager.end_session()           → final save + stop tracking

const MAX_SLOTS := 6
const SAVE_DIR := "user://saves/"
const META_PATH := "user://saves/meta.tres"
const AUTO_SAVE_INTERVAL := 60.0

var data: PlayerData = null
var active_slot: int = -1
var is_loading: bool = false  ## Guard: prevents save triggers during load

var _auto_save_timer: Timer = null
var _is_in_game: bool = false
var _play_time_accumulator: float = 0.0


func _ready() -> void:
	_ensure_save_dir()
	_setup_auto_save_timer()


func _process(delta: float) -> void:
	if _is_in_game and data != null:
		_play_time_accumulator += delta


# =============================================================================
# Slot Management
# =============================================================================

func get_slot_path(slot_index: int) -> String:
	return SAVE_DIR + "slot_%d.tres" % slot_index


func get_slot_data(slot_index: int) -> PlayerData:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return null

	var path := get_slot_path(slot_index)
	if not FileAccess.file_exists(path):
		return null

	var resource := ResourceLoader.load(path)
	if resource is PlayerData:
		return resource as PlayerData

	return null


func is_slot_occupied(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return false
	return FileAccess.file_exists(get_slot_path(slot_index))


func delete_slot(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		return

	var path := get_slot_path(slot_index)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

	# If we deleted the active slot, clear session
	if slot_index == active_slot:
		data = null
		active_slot = -1
		_is_in_game = false


func get_all_slot_summaries() -> Array[Dictionary]:
	var result: Array[Dictionary] = []

	for i in range(MAX_SLOTS):
		var summary := {
			"index": i,
			"occupied": false,
			"timestamp": "",
			"play_time": 0.0,
		}

		var slot_data := get_slot_data(i)
		if slot_data != null:
			summary["occupied"] = true
			summary["timestamp"] = slot_data.save_timestamp
			summary["play_time"] = slot_data.play_time_seconds

		result.append(summary)

	return result


# =============================================================================
# Game Flow
# =============================================================================

func new_game(slot_index: int) -> void:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		push_error("SaveManager.new_game: invalid slot index %d" % slot_index)
		return

	# Delete existing save in this slot if any
	delete_slot(slot_index)

	data = PlayerData.new()
	active_slot = slot_index
	_play_time_accumulator = 0.0
	_save_meta()


func load_game(slot_index: int) -> bool:
	if slot_index < 0 or slot_index >= MAX_SLOTS:
		push_error("SaveManager.load_game: invalid slot index %d" % slot_index)
		return false

	var loaded := get_slot_data(slot_index)
	if loaded == null:
		push_warning("SaveManager.load_game: slot %d is empty." % slot_index)
		return false

	data = loaded
	active_slot = slot_index
	_play_time_accumulator = data.play_time_seconds
	_save_meta()
	return true


func save_game() -> void:
	if data == null or active_slot < 0:
		return

	if is_loading:
		return

	_capture_from_player()

	data.play_time_seconds = _play_time_accumulator
	data.save_timestamp = Time.get_datetime_string_from_system(false, true)

	var path := get_slot_path(active_slot)
	var err := ResourceSaver.save(data, path)
	if err != OK:
		push_error("SaveManager: failed to save to %s (error %d)" % [path, err])


func start_session() -> void:
	_is_in_game = true
	if _auto_save_timer != null:
		_auto_save_timer.start(AUTO_SAVE_INTERVAL)


func end_session() -> void:
	save_game()
	_is_in_game = false
	if _auto_save_timer != null:
		_auto_save_timer.stop()


# =============================================================================
# State Capture / Push
# =============================================================================

func _capture_from_player() -> void:
	if data == null:
		return

	var player := _find_player()
	if player == null:
		return

	if player.has_method("save_state"):
		player.save_state()


func push_to_player() -> void:
	if data == null:
		return

	var player := _find_player()
	if player == null:
		return

	is_loading = true

	if player.has_method("load_state"):
		player.load_state()

	is_loading = false


func _find_player() -> Node:
	var tree := get_tree()
	if tree == null:
		return null
	return tree.get_first_node_in_group("player")


# =============================================================================
# Auto-Save
# =============================================================================

func _setup_auto_save_timer() -> void:
	_auto_save_timer = Timer.new()
	_auto_save_timer.one_shot = false
	_auto_save_timer.autostart = false
	_auto_save_timer.timeout.connect(_on_auto_save)
	add_child(_auto_save_timer)


func _on_auto_save() -> void:
	if _is_in_game:
		save_game()


## Called by signal-based auto-save (inventory/equipment changes).
func on_data_changed() -> void:
	if _is_in_game and not is_loading:
		save_game()


# =============================================================================
# Meta (Last-Used Slot)
# =============================================================================

func _save_meta() -> void:
	var meta := SaveMeta.new()
	meta.last_slot_index = active_slot
	ResourceSaver.save(meta, META_PATH)


func get_last_slot() -> int:
	if not FileAccess.file_exists(META_PATH):
		return -1

	var resource := ResourceLoader.load(META_PATH)
	if resource is SaveMeta:
		return (resource as SaveMeta).last_slot_index

	return -1


# =============================================================================
# Helpers
# =============================================================================

func _ensure_save_dir() -> void:
	if not DirAccess.dir_exists_absolute(SAVE_DIR):
		DirAccess.make_dir_recursive_absolute(SAVE_DIR)
