extends Node
class_name Room

@export var room_id: int = 0

@onready var player_packed_scene = preload("res://scenes/player.tscn")
var player: Player = null

func _ready() -> void:
	GlobalState.set_current_room(name)

	var level_data = NavigationManager.level_dictionary[0]
	var room_data = level_data.Rooms[NavigationManager.current_room]

	load_room_doors(room_data.Doors)

	spawn_player()

	await get_tree().process_frame

	if NavigationManager.spawn_door_tag != null:
		spawn_player_at_tag(NavigationManager.spawn_door_tag)


# --------------------------
# PLAYER LOGIC
# --------------------------
func spawn_player():
	if NavigationManager.player:
		add_child(NavigationManager.player)
		player = NavigationManager.player
	else:
		player = player_packed_scene.instantiate()
		NavigationManager.player = player
		add_child(player)


func spawn_player_at_tag(tag: String):
	var door_name = "Door_" + tag
	var door = find_door_by_name(door_name)

	if door:
		player.global_position = door.spawn.global_position
		#player.set_direction(door.spawn_direction)
	else:
		push_warning("Spawn door not found: " + door_name)


# --------------------------
# DOOR LOGIC
# --------------------------
func load_room_doors(door_array: Array) -> void:
	var doors_node = get_node("Doors")

	for door_node in doors_node.get_children():
		# Match JSON data by node name
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


func apply_door_data(door_node: Door, data):
	door_node.destination_level_tag = data.Destination_Level_Tag
	door_node.destination_door_tag = data.Destination_Door_Tag
	door_node.spawn_direction = data.Spawn_Direction
	door_node.teleport = data.Teleport
