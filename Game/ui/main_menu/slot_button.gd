extends PanelContainer
class_name SlotButton

signal slot_selected(index: int)
signal slot_delete_requested(index: int)

@onready var slot_label: Label = $HBoxContainer/SlotInfo/SlotLabel
@onready var details_label: Label = $HBoxContainer/SlotInfo/DetailsLabel
@onready var delete_button: Button = $HBoxContainer/DeleteButton

var slot_index: int = 0
var is_occupied: bool = false


func _ready() -> void:
	delete_button.pressed.connect(_on_delete_pressed)
	gui_input.connect(_on_gui_input)
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func setup(index: int, summary: Dictionary) -> void:
	slot_index = index
	is_occupied = summary.get("occupied", false)

	if is_occupied:
		var timestamp: String = summary.get("timestamp", "")
		var play_time: float = summary.get("play_time", 0.0)
		slot_label.text = "Slot %d" % (index + 1)
		details_label.text = "%s  •  %s played" % [
			_format_timestamp(timestamp),
			_format_play_time(play_time),
		]
		delete_button.visible = true
	else:
		slot_label.text = "Slot %d — Empty" % (index + 1)
		details_label.text = ""
		delete_button.visible = false


func set_selectable(selectable: bool) -> void:
	if selectable:
		mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		modulate = Color.WHITE
	else:
		mouse_default_cursor_shape = Control.CURSOR_ARROW
		modulate = Color(1.0, 1.0, 1.0, 0.4)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		slot_selected.emit(slot_index)


func _on_delete_pressed() -> void:
	slot_delete_requested.emit(slot_index)


func _format_timestamp(timestamp: String) -> String:
	if timestamp.is_empty():
		return "Unknown date"
	return timestamp


func _format_play_time(seconds: float) -> String:
	var total_seconds := int(seconds)
	var hours := total_seconds / 3600
	var minutes := (total_seconds % 3600) / 60
	var secs := total_seconds % 60

	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	elif minutes > 0:
		return "%dm %ds" % [minutes, secs]
	else:
		return "%ds" % secs
