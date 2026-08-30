extends Node2D
class_name Room

@export var room_id: int = 0

@onready var player_packed_scene = preload("res://scenes/player.tscn")
@onready var Player = NavigationManager.Player

# --------------------------
# LIGHTING PRESETS (shared across all rooms)
# --------------------------
const COLOR_NORMAL      := Color(1, 1, 1, 1)
const COLOR_DARK_ROOM   := Color(0.128, 0.128, 0.249, 1.0)
const COLOR_EMERGENCY   := Color(0.45, 0.05, 0.05, 1.0)
const COLOR_BLACKOUT    := Color(0, 0, 0, 1)

@onready var modulate_node: CanvasModulate = $CanvasModulate
@onready var dream_effect: CanvasLayer = $DreamEffect if has_node("DreamEffect") else null
@onready var glitch_effect: CanvasLayer = $GlitchLayer if has_node("GlitchLayer") else null

var flicker_tween: Tween = null

	
func _ready() -> void:
	GlobalState.set_current_room(name)

	var level_data = NavigationManager.level_dictionary[0]
	var room_data = level_data.Rooms[NavigationManager.current_room]

	load_room_doors(room_data.Doors)

	spawn_player()

	await get_tree().process_frame

	if NavigationManager.spawn_door_tag != null:
		spawn_player_at_tag(NavigationManager.spawn_door_tag)

	# Apply shared lighting logic
	apply_state_lighting()
	GlobalState.connect("state_changed", Callable(self, "_on_state_changed"))
	GlobalState.set_room_state(name, "visited", true)

# --------------------------
# PLAYER LOGIC
# --------------------------
func spawn_player():
	if NavigationManager.Player:
		Player = NavigationManager.Player
		if Player.get_parent() != self:
			add_child(Player)
	else:
		Player = player_packed_scene.instantiate()
		NavigationManager.Player = Player
		add_child(Player)

func spawn_player_at_tag(tag: String):
	var door = find_door_by_name("Door_" + tag)
	if door:
		Player.global_position = door.spawn.global_position
	else:
		var marker = get_node_or_null("SpawnPoints/" + tag)
		if marker:
			spawn_player()
			Player.global_position = marker.global_position
		else:
			push_warning("Spawn tag not found as door or marker: " + tag)

func spawn_player_at_marker(marker_name: String, direction: String = ""):
	var marker = get_node_or_null("SpawnPoints/" + marker_name)
	if marker:
		spawn_player()
		Player.global_position = marker.global_position
		if direction != "":
			Player.set_direction(direction)
	else:
		push_warning("Spawn marker not found: " + marker_name)

# --------------------------
# DOOR LOGIC
# --------------------------
func load_room_doors(door_array: Array) -> void:
	var doors_node = get_node("Doors")
	for door_node in doors_node.get_children():
		var data = get_door_data(door_array, door_node.name)
		if data:
			apply_door_data(door_node, data)
		else:
			push_warning("No JSON data for door: " + door_node.name)

func find_door_by_name(name: String):
	var doors_node = get_node("Doors")
	for door in doors_node.get_children():
		if door.name == name:
			return door
	return null

func get_door_data(door_array: Array, door_name: String):
	for d in door_array:
		if d.Name == door_name:
			return d
	return null

func apply_door_data(door_node, data):
	door_node.destination_level_tag = data.Destination_Level_Tag
	door_node.destination_door_tag = data.Destination_Door_Tag
	door_node.spawn_direction = data.Spawn_Direction
	door_node.teleport = data.Teleport

# --------------------------
# LIGHTING / GLOBAL ROOM STATES
# --------------------------
func _on_state_changed(changed_room_name):
	if changed_room_name == name:
		apply_state_lighting()

func apply_state_lighting() -> void:
	var room_name = self.name

	if dream_effect:
		dream_effect.visible = GlobalState.get_room_state(room_name, "dream")
		
	if glitch_effect:
		glitch_effect.visible = GlobalState.get_room_state(room_name, "glitch")

	if GlobalState.events.get("emergency_mode", false) \
			or GlobalState.get_room_state(room_name, "emergency"):
		fade_to_emergency(0, true)
		#start_emergency_flicker()

	elif GlobalState.events.get("blackout", false) \
			or GlobalState.get_room_state(room_name, "blackout"):
		fade_to_blackout(0, true)

	elif GlobalState.get_room_state(room_name, "dark"):
		fade_to_dark_room(0, true)

	else:
		fade_to_normal(0, true)
		stop_flicker()

# --------------------------
# PUBLIC LIGHTING CONTROLS
# --------------------------
func fade_to_normal(duration := 0.8, no_fade := false) -> void:
	_fade_to(COLOR_NORMAL, duration, no_fade)

func fade_to_dark_room(duration := 0.0, no_fade := false) -> void:
	_fade_to(COLOR_DARK_ROOM, duration, no_fade)

func fade_to_emergency(duration := 0.8, no_fade := false) -> void:
	_fade_to(COLOR_EMERGENCY, duration, no_fade)

func fade_to_blackout(duration := 0.7, no_fade := false) -> void:
	_fade_to(COLOR_BLACKOUT, duration, no_fade)

# --------------------------
# FLICKER SYSTEM
# --------------------------
func start_emergency_flicker(strength := 0.07, speed := 0.12) -> void:
	stop_flicker()
	flicker_tween = create_tween().set_loops()

	var brighter = Color(
		COLOR_EMERGENCY.r + strength,
		COLOR_EMERGENCY.g + strength * 0.2,
		COLOR_EMERGENCY.b + strength * 0.2
	)
	var darker = Color(
		COLOR_EMERGENCY.r - strength,
		COLOR_EMERGENCY.g - strength * 0.2,
		COLOR_EMERGENCY.b - strength * 0.2
	)

	flicker_tween.tween_property(modulate_node, "color", brighter, speed)
	flicker_tween.tween_property(modulate_node, "color", darker, speed)

func stop_flicker() -> void:
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	flicker_tween = null

func _fade_to(target: Color, duration: float, no_fade: bool = false) -> void:
	stop_flicker()
	if no_fade:
		modulate_node.color = target
		return

	var t := create_tween()
	t.tween_property(modulate_node, "color", target, duration)
