extends CharacterBody2D

class_name Player

@onready var actionable_finder: Area2D = $Direction/ActionableFinder
@onready var actionable_finder_ground: Area2D = $Direction/ActionableFinderGround
@onready var light: PointLight2D = $PointLight2D

@export var speed = 100
var curr_dir = "down"
var current_room: String = ""

var action_area_offsets := {
	"up": Vector2(0, -8),
	"down": Vector2(0, 16),
	"left": Vector2(-8, 4),
	"right": Vector2(8, 4)
}


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
	if not Input.is_action_just_pressed("interact"):
		return

	# Try directional 
	var actionables = actionable_finder.get_overlapping_areas()
	if actionables.size() > 0:
		actionables[0].action()
		return

	# Fallback to ground items
	var ground_actionables = actionable_finder_ground.get_overlapping_areas()
	if ground_actionables.size() > 0:
		ground_actionables[0].action()

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
		update_direction(input_vector)
		play_anim(true)
		var motion = input_vector * speed * _delta

		var collision = move_and_collide(motion)
		if collision:
			return
	else:
		play_anim(false)
	
	actionable_finder.position = action_area_offsets.get(curr_dir, Vector2.ZERO)

func update_direction(input_vector: Vector2) -> void:
	if abs(input_vector.x) > abs(input_vector.y):
		curr_dir = "right" if input_vector.x > 0 else "left"
	else:
		curr_dir = "down" if input_vector.y > 0 else "up"

func play_anim(moving: bool) -> void:
	var anim = $AnimatedSprite2D
	match curr_dir:
		"left":
			anim.flip_h = true
			anim.play("side_walk" if moving else "side_idle")
		"right":
			anim.flip_h = false
			anim.play("side_walk" if moving else "side_idle")
		"up":
			anim.flip_h = false
			anim.play("back_walk" if moving else "back_idle")
		"down":
			anim.flip_h = false
			anim.play("front_walk" if moving else "front_idle")
			
func play_anim_with_dir(dir: String) -> void:
	curr_dir = dir
	play_anim(false)
