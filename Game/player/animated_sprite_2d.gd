extends AnimatedSprite2D

@export var levitation_speed: float = 3.0   # How fast it moves up and down
@export var levitation_height: float = 5.0  # Maximum distance up or down

var _base_position: Vector2
var _time_passed: float = 0.0

func _ready():
	_base_position = position  # Store the original position

func _process(delta):
	_time_passed += delta * levitation_speed
	position.y = _base_position.y + sin(_time_passed) * levitation_height
