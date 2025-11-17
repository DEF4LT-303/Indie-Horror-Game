extends CharacterBody2D

@onready var actionable = $Actionable
const NPC_NAME := "boy"

func _ready():
	# Remove NPC if already talked to
	if GlobalState.npc_has_been_talked_to(NPC_NAME):
		queue_free()
		return

	actionable.action_requested.connect(_on_action)

func _on_action(dialogue_resource, dialogue_start):
	# Show dialogue
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	GlobalState.npcs["boy"]["talked"] = true
	
	# Mark NPC as pending removal (after dialogue)
	GlobalState.mark_npc_pending_removal(NPC_NAME)
