extends CharacterBody2D

class_name Player

@export var speed = 100
var curr_dir = "down"

@onready var actionable_finder: Area2D = $Direction/ActionableFinder

func _ready() -> void:
	$AnimatedSprite2D.play("front_idle")
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	
func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("interact"):
		var actionables = actionable_finder.get_overlapping_areas()
		if actionables.size() > 0:
			actionables[0].action()
			return

func _on_spawn(position: Vector2, direction: String) -> void:
	global_position = position
	curr_dir = direction
	
func _input(_event):
	if GlobalState.dialogue_active:
		return 


func _physics_process(_delta: float) -> void:
	if GlobalState.dialogue_active:
		velocity = Vector2.ZERO
		return
		
	var input_vector = Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		input_vector.x = 1
	elif Input.is_action_pressed("ui_left"):
		input_vector.x = -1
	elif Input.is_action_pressed("ui_down"):
		input_vector.y = 1
	elif Input.is_action_pressed("ui_up"):
		input_vector.y = -1

	if input_vector != Vector2.ZERO:
		velocity = input_vector * speed
		update_direction(input_vector)
		play_anim(true)
	else:
		velocity = Vector2.ZERO
		play_anim(false)

	move_and_slide()

func update_direction(input_vector: Vector2) -> void:
	if abs(input_vector.x) > abs(input_vector.y):
		curr_dir = "right" if input_vector.x > 0 else "left"
	else:
		curr_dir = "down" if input_vector.y > 0 else "up"

func play_anim(moving: bool) -> void:
	var anim = $AnimatedSprite2D
	match curr_dir:
		"right":
			anim.flip_h = true
			anim.play("side_walk" if moving else "side_idle")
		"left":
			anim.flip_h = false
			anim.play("side_walk" if moving else "side_idle")
		"up":
			anim.flip_h = false
			anim.play("back_walk" if moving else "back_idle")
		"down":
			anim.flip_h = false
			anim.play("front_walk" if moving else "front_idle")
