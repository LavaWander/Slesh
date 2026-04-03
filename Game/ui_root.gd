extends CanvasLayer

@onready var hud: Control = $HUD
@onready var inventory_panel: Control = $InventoryPanel
@onready var stats_panel: Control = $StatsPanel


func _ready() -> void:
	hud.inventory_toggle_requested.connect(_on_inventory_toggle_requested)
	hud.stats_toggle_requested.connect(_on_stats_toggle_requested)
	hud.inventory_exit_requested.connect(_on_inventory_exit_requested)

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
