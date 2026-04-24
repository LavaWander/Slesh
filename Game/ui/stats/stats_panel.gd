extends Control

@export var stat_row_scene: PackedScene

@onready var search_box: LineEdit = $Background/SearchBox
@onready var stats_list: VBoxContainer = $Background/StatsScroll/StatsList

var player: Node = null
var stats: StatsComponent = null
var search_text := ""

func _ready() -> void:
	visible = false
	_find_player()
	_cache_stats()

	search_box.text_changed.connect(_on_search_text_changed)
	search_box.focus_entered.connect(_on_search_focus_entered)
	search_box.focus_exited.connect(_on_search_focus_exited)

func _find_player() -> void:
	player = get_tree().get_first_node_in_group("player")

func _cache_stats() -> void:
	if player == null:
		push_warning("StatsPanel could not find player.")
		return

	stats = player.get_node_or_null("StatsComponent") as StatsComponent
	if stats == null:
		push_warning("StatsPanel could not find StatsComponent.")
		return

	if not stats.stats_changed.is_connected(_on_stats_changed):
		stats.stats_changed.connect(_on_stats_changed)

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

func _on_stats_changed() -> void:
	if visible:
		_refresh()

func _on_search_text_changed(new_text: String) -> void:
	search_text = new_text.strip_edges().to_lower()
	if visible:
		_refresh()

func _refresh() -> void:
	for child in stats_list.get_children():
		child.queue_free()

	if stats == null or stat_row_scene == null:
		return

	for breakdown in stats.get_all_breakdowns():
		var label_text: String = String(breakdown.label).to_lower()
		if search_text != "" and not label_text.contains(search_text):
			continue

		var row = stat_row_scene.instantiate()
		stats_list.add_child(row)
		row.set_breakdown(breakdown)

func _on_search_focus_entered() -> void:
	UIState.block_game_input = true

func _on_search_focus_exited() -> void:
	UIState.block_game_input = false
