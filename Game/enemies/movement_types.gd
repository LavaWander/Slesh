class_name MovementTypes


# -------------------
# IDLE
# -------------------
# Do nothing
static func idle() -> Vector2:
	return Vector2.ZERO


# -------------------
# WANDER
# -------------------
# Move randomly within a radius from spawn point
# enemy must provide:
# - global_position
# - a stored wander_target (Vector2)
# - a move_speed
static func wander(enemy, max_distance: float) -> Vector2:
	var to_target = enemy.wander_target - enemy.global_position
	
	# if no target or reached target → pick new one
	if to_target.length() < 10:
		var random_offset = Vector2(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
		).normalized() * randf_range(0, max_distance)

		enemy.wander_target = enemy.spawn_position + random_offset
		to_target = enemy.wander_target - enemy.global_position

	return to_target.normalized() * enemy.move_speed


# -------------------
# ENGAGE
# -------------------
# Maintain a distance from the player
# enemy must provide:
# - player reference
# - move_speed
# - distance_tolerance (small buffer)
static func engage(enemy, preferred_distance: float) -> Vector2:
	if not enemy.player:
		return Vector2.ZERO

	var to_player = enemy.player.global_position - enemy.global_position
	var distance = to_player.length()
	var dir = to_player.normalized()

	var tolerance = enemy.distance_tolerance

	if distance > preferred_distance + tolerance:
		return dir * enemy.move_speed

	elif distance < preferred_distance - tolerance:
		return -dir * enemy.move_speed

	else:
		return Vector2.ZERO


# -------------------
# RECOVER
# -------------------
# Retreat out of aggro range, then return to spawn if safe
# enemy must provide:
# - player reference
# - spawn_position
# - move_speed
# - aggro_range
static func recover(enemy) -> Vector2:
	var to_spawn = enemy.spawn_position - enemy.global_position
	
	if not enemy.player:
		# no player → go home
		return to_spawn.normalized() * enemy.move_speed

	var to_player = enemy.player.global_position - enemy.global_position
	var distance = to_player.length()

	# Step 1: retreat if player is close
	if distance < enemy.aggro_range:
		return -to_player.normalized() * enemy.move_speed

	# Step 2: return to spawn
	if to_spawn.length() < 10:
		return Vector2.ZERO

	return to_spawn.normalized() * enemy.move_speed
