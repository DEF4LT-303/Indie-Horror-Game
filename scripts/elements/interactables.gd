extends Node2D

func _ready():
	# Loop through all children and connect Area2D signals
	for child in get_children():
		var area: Area2D = child.get_node_or_null("Area2D")
		if area:
			area.action_requested.connect(_on_action)

func _on_action(dialogue_res, dialogue_start):
	GlobalState.player_can_move = false 

	DialogueManager.show_dialogue_balloon(dialogue_res, dialogue_start)
	await DialogueManager.dialogue_ended
	
	GlobalState.player_can_move = true 
