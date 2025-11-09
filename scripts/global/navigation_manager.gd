extends Node



signal on_trigger_player_spawn

var current_room : int = 0
var destination_door 
var spawn_door_tag

var player : Player = null

var level_dictionary
var room_array : Array

func go_to_level(destination_level_tag, destination_door_tag) -> void:
	current_room = int(destination_level_tag)
	destination_door = "Door_" + destination_door_tag
	#TransitionScene.transition()
	#await TransitionScene.on_transition_finished
	spawn_door_tag = destination_door_tag
	#print("spawn_door_tag: " + spawn_door_tag)
	var roomData = level_dictionary[0].Rooms[int(destination_level_tag)]
	print("Loading room: ", "res://Scenes/" + roomData.Room_Node)
	var scene_to_load : PackedScene =  load("res://scenes/"+ roomData.Room_Node)
	get_tree().change_scene_to_packed.bind(scene_to_load).call_deferred()

func trigger_player_spawn(position: Vector2, direction:String):
	on_trigger_player_spawn.emit(position, direction)


func load_data_dictionary(dictionary_json):
	var json_as_text = FileAccess.get_file_as_string(dictionary_json)
	level_dictionary = JSON.parse_string(json_as_text)
	
