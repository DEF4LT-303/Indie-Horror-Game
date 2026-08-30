extends Node2D

func _ready():
	# Loop through all children and connect Area2D signals
	for child in get_children():
		var area: Area2D = child.get_node_or_null("Area2D")
		if area:
			area.action_requested.connect(_on_action)

func _on_action(dialogue_res, dialogue_start):
	# Case 1: DIALOGUE
	if dialogue_res != null:
		_handle_dialogue(dialogue_res, dialogue_start)
		return

	# Case 2: NON-DIALOGUE → light switch or anything else
	_handle_switch_action()

func _handle_dialogue(dialogue_res, dialogue_start):
	GlobalState.player_can_move = false
	DialogueManager.show_dialogue_balloon(dialogue_res, dialogue_start)
	await DialogueManager.dialogue_ended
	GlobalState.player_can_move = true


func _handle_switch_action():
	var room = GlobalState.current_room
	var current_state = GlobalState.get_room_state(room, "dark", true)
	var new_state = !current_state

	GlobalState.set_room_state(room, "dark", new_state)
	AudioManager.play_sfx("res://assets/audio/SFX/light_switch.mp3", -6)
