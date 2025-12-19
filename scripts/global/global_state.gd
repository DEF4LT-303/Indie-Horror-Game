extends Node

## Manages all Global states

signal state_changed(room_name)
signal item_collected(item_name)
signal current_room_changed(room_name)

# ------------------------------------
# PLAYER CONTROL
# ------------------------------------
var player_can_move = true

# ------------------------------------
# TIME SYSTEM
# ------------------------------------
var current_day := 1
var time_of_day := 0.0
var current_room: String = ""


# ------------------------------------
# NPC STATE
# ------------------------------------
var npcs := {
	"boy": {
		"talked_to": false,
		"pending_removal": false,
		"position": "bathroom"
	}
}


# ------------------------------------
# STORY / EVENT FLAGS
# ------------------------------------
var events := {
	"basement_light_on": false,
	"first_jumpscare": false,
	"emergency_mode": false,  
	"blackout": false,        
}


# ------------------------------------
# ROOM STATES 
# ------------------------------------
var rooms := {
	"LevelBedroom": {
		"dark": true,
		"blackout": false,
		"emergency": false,
		"dream": true,
		"visited": false,
		"intro_cutscene": false,
		"bgm_override": "res://assets/audio/BGM/bedroom_nightmare.mp3",
		"ambient_override": "res://assets/audio/BGM/indoor-rain-bg.mp3",
	},
	"LevelBathroom": {
		"dark": false,
		"blackout": true,
		"emergency": false,
		"dream": true,
		"visited": false,
		"bgm_override": null,
		"ambient_override": "res://assets/audio/BGM/indoor-rain-bg.mp3",
	}
}

# ------------------------------------
# ITEM SYSTEM
# ------------------------------------
var items := {
	"knife": {
		"collected": false,
		"visible": false
	},
	"letter": {
		"collected": false,
		"visible": true
	}
}

var inventory := {}

# ---------------------------------------------------
# PLAYER METHODS
# ---------------------------------------------------

# ---------------------------------------------------
# NPC METHODS
# ---------------------------------------------------
func mark_npc_pending_removal(npc_name: String):
	if npcs.has(npc_name):
		npcs[npc_name]["pending_removal"] = true


func remove_npc_if_pending(npc_node: Node):
	var name = npc_node.name
	if npcs.has(name) and npcs[name]["pending_removal"]:
		npc_node.queue_free()
		npcs[name]["pending_removal"] = false


func npc_has_been_talked_to(npc_name: String) -> void:
	npcs[npc_name]["talked_to"] = true


func is_npc_talked_to(npc_name: String) -> bool:
	return npcs.has(npc_name) and npcs[npc_name]["talked_to"]


# ---------------------------------------------------
# ITEM METHODS
# ---------------------------------------------------
func mark_item_collected(item_name: String) -> void:
	if items.has(item_name):
		items[item_name]["collected"] = true
		items[item_name]["visible"] = false
		emit_signal("item_collected", item_name)


func is_item_collected(item_name: String) -> bool:
	return items.has(item_name) and items[item_name]["collected"]


func is_item_visible(item_name: String) -> bool:
	return items.has(item_name) and items[item_name]["visible"]


# ---------------------------------------------------
# ROOM STATE METHODS
# ---------------------------------------------------
func get_room_state(room_name: String, key: String, default := false) -> bool:
	if not rooms.has(room_name):
		return default
	return rooms[room_name].get(key, default)
	
func set_room_state(room_name: String, key: String, value) -> void:
	if not rooms.has(room_name):
		return
	rooms[room_name][key] = value
	emit_signal("state_changed", room_name)

func set_bgm_override(room_name: String, path: String) -> void:
	if not rooms.has(room_name):
		return
	rooms[room_name]["bgm_override"] = path
	emit_signal("state_changed", room_name)

func clear_bgm_override(room_name: String) -> void:
	if not rooms.has(room_name):
		return
	rooms[room_name]["bgm_override"] = null
	emit_signal("state_changed", room_name)

func set_ambient_override(room_name: String, path: String) -> void:
	if not rooms.has(room_name):
		return
	rooms[room_name]["ambient_override"] = path
	emit_signal("state_changed", room_name)

func clear_ambient_override(room_name: String) -> void:
	if not rooms.has(room_name):
		return
	rooms[room_name]["ambient_override"] = null
	emit_signal("state_changed", room_name)


func set_current_room(room_name: String) -> void:
	if current_room == room_name:
		return
	current_room = room_name
	current_room_changed.emit(room_name)
	
func get_current_room_node() -> Node:
	if current_room == "" or current_room == null:
		return null

	var root = get_tree().get_current_scene()
	return root.get_node_or_null(current_room)
