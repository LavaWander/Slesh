extends Control
class_name ItemSlotUI

signal clicked(item: ItemData)
signal hovered(item: ItemData)
signal unhovered

var item: ItemData = null

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(item)


func _on_mouse_entered() -> void:
	print("entered item slot: ", item)
	if item != null:
		hovered.emit(item)


func _on_mouse_exited() -> void:
	print("exited item slot")
	unhovered.emit()


func set_item(new_item: ItemData, quantity: int) -> void:
	item = new_item

	if item == null:
		icon.texture = null
		quantity_label.text = ""
		set_equipped_highlight(false)
		return

	icon.texture = item.icon

	if quantity > 1:
		quantity_label.text = str(quantity)
	else:
		quantity_label.text = ""

	set_equipped_highlight(false)


func set_equipped_highlight(is_equipped: bool) -> void:
	if is_equipped:
		background.color = Color(0.2, 0.8, 0.2, 1.0)
	else:
		background.color = Color.from_rgba8(50, 50, 50, 255)
