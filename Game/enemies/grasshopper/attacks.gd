class_name Attacks

var enemy

func _init(owner):
	enemy = owner

func throw_stick(direction: Vector2) -> void:
	ProjectileSpawner.spawn(
		enemy.throw_stick_config,
		enemy.global_position,
		direction,
		enemy
	)
