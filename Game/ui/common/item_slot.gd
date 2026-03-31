extends Control

var item: ItemData = null

@onready var icon: TextureRect = $Icon
@onready var quantity_label: Label = $QuantityLabel


func set_item(new_item: ItemData, quantity: int) -> void:
	item = new_item

	if item == null:
		icon.texture = null
		quantity_label.text = ""
		return

	icon.texture = item.icon
	
	if quantity > 1:
		quantity_label.text = str(quantity)
	else:
		quantity_label.text = ""
	quantity_label.text = str(quantity)
