extends Panel
class_name ItemTooltip

@onready var primary_name_label: Label = $MarginContainer/VBoxContainer/PrimaryNameLabel
@onready var primary_stats_label: Label = $MarginContainer/VBoxContainer/PrimaryStatsLabel
@onready var separator: HSeparator = $MarginContainer/VBoxContainer/Separator
@onready var compare_name_label: Label = $MarginContainer/VBoxContainer/CompareNameLabel
@onready var compare_stats_label: Label = $MarginContainer/VBoxContainer/CompareStatsLabel

var is_showing: bool = false


func _ready() -> void:
	visible = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _process(_delta: float) -> void:
	if not visible:
		return

	global_position = get_viewport().get_mouse_position()


func show_tooltip(item: ItemData, compare_item: ItemData = null) -> void:
	if item == null:
		hide_tooltip()
		return

	primary_name_label.text = _get_item_name(item)
	primary_stats_label.text = _build_stats_text(item)

	if compare_item != null:
		separator.visible = true
		compare_name_label.visible = true
		compare_stats_label.visible = true

		compare_name_label.text = "Equipped: " + _get_item_name(compare_item)
		compare_stats_label.text = _build_stats_text(compare_item)
	else:
		separator.visible = false
		compare_name_label.visible = false
		compare_stats_label.visible = false
		compare_name_label.text = ""
		compare_stats_label.text = ""

	visible = true
	is_showing = true

	# Let layout update itself to the text content
	reset_size()
	size = Vector2.ZERO
	custom_minimum_size = Vector2.ZERO


func hide_tooltip() -> void:
	visible = false
	is_showing = false


func _get_item_name(item: ItemData) -> String:
	if item.display_name != "":
		return item.display_name
	return String(item.item_id)


func _build_stats_text(item: ItemData) -> String:
	if item == null or item.modifiers.is_empty():
		return "No stats"

	var lines: Array[String] = []

	for modifier in item.modifiers:
		if modifier == null:
			continue

		var stat_name: String = _format_stat_name(_get_modifier_stat_name(modifier))
		var line: String

		match modifier.mode:
			StatModifier.Mode.ADD:
				if modifier.value >= 0:
					line = "+%s %s" % [_format_value(modifier.value), stat_name]
				else:
					line = "%s %s" % [_format_value(modifier.value), stat_name]
			StatModifier.Mode.MULTIPLY:
				line = "x%s %s" % [_format_value(modifier.value), stat_name]
			_:
				line = "%s %s" % [_format_value(modifier.value), stat_name]

		lines.append(line)

	if lines.is_empty():
		return "No stats"

	return "\n".join(lines)


func _format_stat_name(stat_name: StringName) -> String:
	var text := String(stat_name)
	text = text.replace("_", " ")
	return text.capitalize()


func _format_value(value: float) -> String:
	if is_equal_approx(value, round(value)):
		return str(int(round(value)))
	return str(snappedf(value, 0.01))


func _get_modifier_stat_name(modifier: StatModifier) -> StringName:
	if modifier == null:
		return &""

	# supports enum-based StatModifier
	if modifier.has_method("get_stat_name"):
		return modifier.get_stat_name()

	# fallback for older string-based StatModifier
	if "stat_name" in modifier:
		return modifier.stat_name

	return &"unknown_stat"
