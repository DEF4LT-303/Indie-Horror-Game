extends CharacterBody2D

class_name Player

@export var speed = 100
var curr_dir = "down"
var current_room: String = ""

@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var light: PointLight2D = $PointLight2D

func _ready() -> void:
	$AnimatedSprite2D.play("front_idle")
	NavigationManager.on_trigger_player_spawn.connect(_on_spawn)
	GlobalState.connect("state_changed", Callable(self, "_on_room_changed"))
	GlobalState.connect("current_room_changed", Callable(self, "_on_current_room_changed"))
	
	_on_current_room_changed(GlobalState.current_room)

func _update_light():
	# Only enable the light if the current room has blackout OR global blackout event is active
	var room_blackout = GlobalState.get_room_state(GlobalState.current_room, "blackout")
	var event_blackout = GlobalState.events.get("blackout", false)

	light.visible = room_blackout or event_blackout

func _on_room_changed(changed_room_name: String):
	if changed_room_name == current_room:
		_update_light()


func _on_current_room_changed(room_name: String) -> void:
	current_room = room_name
	_update_light()

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
	if not GlobalState.player_can_move:
		return 


func _physics_process(_delta: float) -> void:
	if not GlobalState.player_can_move:
		velocity = Vector2.ZERO
		play_anim(false)
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
