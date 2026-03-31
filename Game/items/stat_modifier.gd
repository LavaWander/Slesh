extends Resource
class_name StatModifier

enum Mode {
	ADD,
	MULTIPLY
}

enum StatId {
	MAX_HEALTH,
	THRUST_DAMAGE,
	THRUST_SIZE,
	THRUST_DURATION,
	THRUST_COOLDOWN,
	THRUST_DISTANCE_MULTIPLIER,
	SLASH_DAMAGE,
	SLASH_SIZE,
	SLASH_DURATION,
	SLASH_COOLDOWN,
	SLASH_ANGLE
}

@export var stat_id: StatId
@export var mode: Mode = Mode.ADD
@export var value: float = 0.0


func get_stat_name() -> StringName:
	match stat_id:
		StatId.MAX_HEALTH:
			return &"max_health"
		StatId.THRUST_DAMAGE:
			return &"thrust_damage"
		StatId.THRUST_SIZE:
			return &"thrust_size"
		StatId.THRUST_DURATION:
			return &"thrust_duration"
		StatId.THRUST_COOLDOWN:
			return &"thrust_cooldown"
		StatId.THRUST_DISTANCE_MULTIPLIER:
			return &"thrust_distance_multiplier"
		StatId.SLASH_DAMAGE:
			return &"slash_damage"
		StatId.SLASH_SIZE:
			return &"slash_size"
		StatId.SLASH_DURATION:
			return &"slash_duration"
		StatId.SLASH_COOLDOWN:
			return &"slash_cooldown"
		StatId.SLASH_ANGLE:
			return &"slash_angle"
		_:
			return &""
