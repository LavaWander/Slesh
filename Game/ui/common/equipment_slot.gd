extends Control
class_name EquipmentSlotUI

signal clicked(slot_name: StringName)

@export var slot_name: StringName

@onready var background: ColorRect = $Background
@onready var icon: TextureRect = $Icon
@onready var slot_label: Label = $SlotLabel

var item: ItemData = null


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		clicked.emit(slot_name)


func set_item(new_item: ItemData) -> void:
	item = new_item

	if item == null:
		icon.texture = null
		slot_label.text = _format_slot_name(slot_name)
		return

	icon.texture = item.icon
	slot_label.text = ""


func _format_slot_name(value: StringName) -> String:
	return String(value).capitalize()
