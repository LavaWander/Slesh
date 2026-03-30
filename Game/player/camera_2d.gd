extends Camera2D

@export var target = "Player"
func _process(_delta):
	if target:
			global_position = get_node(target).global_position
