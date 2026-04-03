extends PanelContainer

@onready var name_label: Label = $MarginContainer/HBoxContainer/NameLabel
@onready var formula_label: Label = $MarginContainer/HBoxContainer/FormulaLabel
@onready var final_value_label: Label = $MarginContainer/HBoxContainer/FinalValueLabel

func set_breakdown(breakdown: Dictionary) -> void:
	name_label.text = breakdown.label + ":"
	formula_label.text = "(%s + %s) x %s = " % [
		breakdown.base_text,
		breakdown.add_text,
		breakdown.mult_text,
	]
	final_value_label.text = breakdown.final_text
