extends Resource
class_name StatModifier

enum Mode {
	ADD,
	MULTIPLY
}

@export var stat_name: StringName
@export var mode: Mode = Mode.ADD
@export var value: float = 0.0
