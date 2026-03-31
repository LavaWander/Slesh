extends CharacterBody2D

enum State {
	IDLE,
	WANDER,
	ENGAGE,
	RECOVER
}

var faction = "enemy"

@onready var health: HealthComponent = $HealthComponent
@export var move_speed: float = 80.0
@export var aggro_range: float = 260.0
@export var preferred_distance: float = 140.0
@export var distance_tolerance: float = 18.0
@export var wander_radius: float = 120.0
@export var attack_range: float = 220.0
@export var attack_cooldown: float = 1.4 # 1.4
@export var aim_time: float = 0.35 # 0.35
@export var throw_stick_config: ProjectileConfig

#var hp: int
var state: State = State.WANDER
var player: Node2D = null
var spawn_position: Vector2
var wander_target: Vector2

var attacks: Attacks
var can_attack: bool = true
var is_aiming: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	spawn_position = global_position
	wander_target = spawn_position
	player = get_tree().get_first_node_in_group("player")
	attacks = Attacks.new(self)
	health.died.connect(_on_died) # new
	_play_idle()
	
	print("player found: ", player)
	print("spawn_position: ", spawn_position)

func _physics_process(delta: float) -> void:
	if not player:
		velocity = Vector2.ZERO
		_play_idle()
		move_and_slide()
		return

	_update_state()

	match state:
		State.IDLE:
			velocity = MovementTypes.idle()

		State.WANDER:
			velocity = MovementTypes.wander(self, wander_radius)

		State.ENGAGE:
			velocity = MovementTypes.engage(self, preferred_distance)

		State.RECOVER:
			velocity = MovementTypes.recover(self)

	_update_facing()
	_update_animation()

	move_and_slide()

	if state == State.ENGAGE and can_attack and not is_aiming:
		var dist := global_position.distance_to(player.global_position)
		if dist <= attack_range:
			_start_stick_attack()
	
	print("state: ", state, " velocity: ", velocity, " player: ", player)


func _update_state() -> void:
	var dist_to_player := global_position.distance_to(player.global_position)
	var low_hp := health.is_low(0.2)

	if low_hp:
		state = State.RECOVER
		return

	match state:
		State.IDLE:
			if dist_to_player <= aggro_range:
				state = State.ENGAGE

		State.WANDER:
			if dist_to_player <= aggro_range:
				state = State.ENGAGE

		State.ENGAGE:
			if dist_to_player > aggro_range * 1.2:
				state = State.WANDER

		State.RECOVER:
			if dist_to_player > aggro_range and global_position.distance_to(spawn_position) < 12.0:
				state = State.WANDER


func _start_stick_attack() -> void:
	can_attack = false
	is_aiming = true

	_play_aim_anim()

	var timer := get_tree().create_timer(aim_time)
	timer.timeout.connect(_throw_stick)


func _throw_stick() -> void:
	if not player:
		is_aiming = false
		_start_attack_cooldown()
		return

	var dir := (player.global_position - global_position).normalized()
	attacks.throw_stick(dir)

	is_aiming = false
	_start_attack_cooldown()


func _start_attack_cooldown() -> void:
	var timer := get_tree().create_timer(attack_cooldown)
	timer.timeout.connect(func() -> void:
		can_attack = true
	)

func _on_died(_source: Node) -> void:
	queue_free()


func _update_facing() -> void:
	if abs(velocity.x) > 1.0:
		sprite.flip_h = velocity.x < 0


func _update_animation() -> void:
	if is_aiming:
		if velocity.length() > 5.0:
			_transition_between_walk_and_walk_stick("walk_stick")
		else:
			if sprite.animation != "stick":
				sprite.play("stick")
		return

	if velocity.length() > 5.0:
		if sprite.animation != "walk":
			_transition_between_walk_and_walk_stick("walk")
	else:
		_play_idle()


func _play_idle() -> void:
	if sprite.animation != "idle":
		sprite.play("idle")


func _play_aim_anim() -> void:
	if velocity.length() > 5.0:
		_transition_between_walk_and_walk_stick("walk_stick")
	else:
		if sprite.animation != "stick":
			sprite.play("stick")


func _transition_between_walk_and_walk_stick(target_anim: String) -> void:
	if sprite.animation == target_anim:
		if not sprite.is_playing():
			sprite.play(target_anim)
		return

	var old_frame := sprite.frame
	sprite.play(target_anim)

	# since walk and walk_stick are both 2 frames,
	# keep the same frame index to make the transition smooth
	var frame_count := sprite.sprite_frames.get_frame_count(target_anim)
	if frame_count > 0:
		sprite.frame = clamp(old_frame, 0, frame_count - 1)
