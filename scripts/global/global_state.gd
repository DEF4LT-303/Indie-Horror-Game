extends Node

var player_can_move = true

var current_day := 1
var time_of_day := 0.0

var npcs := {
	"boy": {
		"talked_to": false,
		"pending_removal": false,
		"position": "bathroom"
	}
}

var events := {
	"basement_light_on": false,
	"first_jumpscare": false,
}

var items := {
	"knife": {
		"collected": false,
		"visible": false
	}
}


var inventory := {}

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
	
func mark_item_collected(item_name: String) -> void:
	if items.has(item_name):
		items[item_name]["collected"] = true
		items[item_name]["visible"] = false

func is_item_collected(item_name: String) -> bool:
	return items.has(item_name) and items[item_name]["collected"]
	
func is_item_visible(item_name: String) -> bool:
	return items.has(item_name) and items[item_name]["visible"]
