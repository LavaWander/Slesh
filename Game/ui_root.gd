extends CanvasLayer

@onready var hud: Control = $HUD
@onready var inventory_panel: Control = $InventoryPanel


func _ready() -> void:
	hud.inventory_toggle_requested.connect(_on_inventory_toggle_requested)
	hud.inventory_exit_requested.connect(_on_inventory_exit_requested)


func _on_inventory_toggle_requested() -> void:
	inventory_panel.toggle()

func _on_inventory_exit_requested() -> void:
	inventory_panel.close()
