extends Node

signal on_trigger_player_spawn

var current_room : int = 0
var destination_door 
var spawn_door_tag

var player : Player = null

var level_dictionary
var room_array : Array

func go_to_level(destination_level_tag, destination_door_tag, fade_out_duration := 1, fade_in_duration := 1) -> void:
	GlobalState.player_can_move = false
	
	current_room = int(destination_level_tag)
	destination_door = "Door_" + destination_door_tag
	
	# Start fade
	TransitionScene.transition(fade_out_duration, fade_in_duration)
	await TransitionScene.on_transition_finished
	
	spawn_door_tag = destination_door_tag
	
	var roomData = level_dictionary[0].Rooms[int(destination_level_tag)]
	var path = "res://scenes/levels/" + roomData.Room_Node
	print("Loading room: ", path)
	
	var scene_to_load: PackedScene = load(path)
	if scene_to_load:
		# Call deferred to avoid issues inside await
		call_deferred("_change_scene", scene_to_load)
	else:
		push_error("Failed to load scene: " + path)
		
	GlobalState.player_can_move = true


func _change_scene(scene: PackedScene) -> void:
	get_tree().change_scene_to_packed(scene)


func trigger_player_spawn(position: Vector2, direction:String):
	on_trigger_player_spawn.emit(position, direction)


func load_data_dictionary(dictionary_json):
	var json_as_text = FileAccess.get_file_as_string(dictionary_json)
	level_dictionary = JSON.parse_string(json_as_text)
	
