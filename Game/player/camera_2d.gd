extends Camera2D

@export var target = "Player"

func _ready() -> void:
	if target:
		_snap_to_target.call_deferred()

func _snap_to_target() -> void:
	global_position = get_node(target).global_position

func _process(_delta):
	if target:
		global_position = get_node(target).global_position
