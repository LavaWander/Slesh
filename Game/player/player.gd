extends CharacterBody2D

@export var base_speed := 200
var speed = base_speed

func _physics_process(_delta):
	speed = base_speed # resets speed
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_running = Input.is_action_pressed("run")
	
	if is_running:
		speed = base_speed * 1.5
	velocity = direction * speed
	move_and_slide()
	
	# handle animation
	var sprite = $AnimatedSprite2D
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

# adds sword
var sword_scene: PackedScene

func _ready():
	add_to_group("player")
	sword_scene = preload("res://sword/sword.tscn")
	var sword_instance = sword_scene.instantiate()
	sword_instance.player = self
	get_parent().add_child.call_deferred(sword_instance)
