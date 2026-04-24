extends Control
class_name LootNotification

@onready var icon: TextureRect = $Icon
@onready var text_label: Label = $TextLabel

@export var lifetime: float = 2.0

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func show_notification(enemy_name: String, item: ItemData, amount: int) -> void:
	if item == null or amount <= 0:
		queue_free()
		return

	var item_name := item.display_name
	if item_name.is_empty():
		item_name = String(item.item_id)

	icon.texture = item.icon
	text_label.text = "%s dropped x%d %s" % [enemy_name, amount, item_name]

	var timer := get_tree().create_timer(lifetime)
	timer.timeout.connect(queue_free)
