extends Node

func spawn(config: ProjectileConfig, pos: Vector2, dir: Vector2, instigator = null):
	if not config.projectile_scene:
		push_warning("ProjectileSpawner: config has no projectile_scene.")
		return null

	var projectile = config.projectile_scene.instantiate()

	if projectile.has_method("initialize"):
		projectile.initialize(config, pos, dir, instigator)
	else:
		projectile.global_position = pos
		if "direction" in projectile:
			projectile.direction = dir

	get_tree().current_scene.add_child(projectile)
	return projectile
