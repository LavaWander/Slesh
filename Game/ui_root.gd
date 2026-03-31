extends CanvasLayer

@onready var hud: Control = $HUD
@onready var inventory_panel: Control = $InventoryPanel


func _ready() -> void:
	hud.inventory_toggle_requested.connect(_on_inventory_toggle_requested)


func _on_inventory_toggle_requested() -> void:
	inventory_panel.toggle()
