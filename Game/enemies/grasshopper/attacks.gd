class_name Attacks

var enemy
var fireball_config: ProjectileConfig

func _init(owner):
	enemy = owner
	
	# load the config from the same folder
	fireball_config = preload("res://enemies/grasshopper/fireball.tres")

func throw_fireball(direction: Vector2):
	ProjectileSpawner.spawn(
		fireball_config,
		enemy.global_position,
		direction
	)
