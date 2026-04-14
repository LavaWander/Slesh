extends CharacterBody2D

@export var base_speed := 200
var speed = base_speed

const DAMAGE_NUMBER_SPAWNER_SCENE := preload("res://ui/world/damage_number_spawner.tscn")
const DAMAGE_NUMBER_SCENE := preload("res://ui/world/damage_number.tscn")

var faction = "player"
signal last_enemy_hit(target: Node, health: HealthComponent)

func _physics_process(_delta):
	if UIState.block_game_input:
		return
		
	speed = base_speed # resets speed
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("run")
	
	if is_running:
		speed = base_speed * 1.5
	velocity = direction * speed
	move_and_slide()
	
	# handle animation
	var sprite: AnimatedSprite2D = $AnimatedSprite2D
	if direction != Vector2.ZERO:
		if is_running:
			sprite.animation = "run"
		else:
			sprite.animation = "walk"
		
		sprite.play()
		
		# flip horizontally depending on direction.x
		if direction.x != 0:
			sprite.flip_h = direction.x < 0
	else:
		sprite.animation = "idle"
		sprite.play()

@onready var inventory: InventoryComponent = $InventoryComponent
@onready var equipment: EquipmentComponent = $EquipmentComponent
@onready var stats: StatsComponent = $StatsComponent
var starter_items := [
	&"business_armor",
	&"godot_armor",
	&"ring1",
	&"ring2",
	&"ring3",
]

func _ready():
	for item_id in starter_items:
		var item := ItemDatabase.get_item(item_id)
		if item != null:
			inventory.add_item(item, 1)

	_spawn_world_ui()
	add_to_group("player")


func register_hit_target(target: Node, health: HealthComponent, instigator: Node) -> void:
	if instigator != self:
		return

	last_enemy_hit.emit(target, health)


func _spawn_world_ui() -> void:
	var damage_number_spawner := DAMAGE_NUMBER_SPAWNER_SCENE.instantiate() as DamageNumberSpawner
	damage_number_spawner.health_path = ^"../HealthComponent"
	damage_number_spawner.collision_shape_path = ^"../Hitbox"
	damage_number_spawner.damage_number_scene = DAMAGE_NUMBER_SCENE
	add_child(damage_number_spawner)
