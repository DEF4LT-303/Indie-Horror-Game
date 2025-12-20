extends CharacterBody2D

@export var move_speed: float = 30.0  # pixels per second
@export var move_distance: float = 30.0  # how far left the NPC moves

var start_x: float
var target_x: float
var moving: bool

func _ready():
	start_x = position.x
	target_x = start_x - move_distance

func _process(delta):
	if moving:
		_move_left(delta)

func _move_left(delta):
	position.x -= move_speed * delta
	if position.x <= target_x:
		position.x = target_x
		moving = false
		_on_movement_finished()

func _on_movement_finished():
	queue_free()  # remove the NPC from the scene

func start_moving():
	if not moving:
		moving = true
