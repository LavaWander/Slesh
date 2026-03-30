extends Node

@export var projectile_scene: PackedScene

func spawn(config, pos: Vector2, dir: Vector2):
	if not projectile_scene:
		push_warning("ProjectileSpawner: projectile_scene not assigned.")
		return null

	var projectile = projectile_scene.instantiate()
	
	if projectile.has_method("initialize"):
		projectile.initialize(config, pos, dir)
	else:
		projectile.global_position = pos
		if "direction" in projectile:
			projectile.direction = dir
	
	get_tree().current_scene.add_child(projectile)
	return projectile
