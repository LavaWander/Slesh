extends Label
class_name ResponsiveFontLabel

enum ScaleMode {
	WIDTH,
	HEIGHT,
	MIN_AXIS,
	MAX_AXIS,
	AVERAGE
}

@export var base_font_size: int = 24
@export var reference_resolution: Vector2 = Vector2(1920, 1080)
@export var scale_mode: ScaleMode = ScaleMode.HEIGHT

@export var min_font_size: int = 8
@export var max_font_size: int = 96


func _ready() -> void:
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_update_font_size):
		viewport.size_changed.connect(_update_font_size)

	_update_font_size()


func _update_font_size() -> void:
	var viewport_size: Vector2 = get_viewport_rect().size

	if reference_resolution.x <= 0.0 or reference_resolution.y <= 0.0:
		push_warning("ResponsiveFontLabel: reference_resolution must be greater than zero.")
		return

	var width_scale: float = viewport_size.x / reference_resolution.x
	var height_scale: float = viewport_size.y / reference_resolution.y

	var final_scale: float = 1.0

	match scale_mode:
		ScaleMode.WIDTH:
			final_scale = width_scale
		ScaleMode.HEIGHT:
			final_scale = height_scale
		ScaleMode.MIN_AXIS:
			final_scale = min(width_scale, height_scale)
		ScaleMode.MAX_AXIS:
			final_scale = max(width_scale, height_scale)
		ScaleMode.AVERAGE:
			final_scale = (width_scale + height_scale) * 0.5

	var final_size: int = int(round(base_font_size * final_scale))
	final_size = clamp(final_size, min_font_size, max_font_size)

	add_theme_font_size_override("font_size", final_size)
