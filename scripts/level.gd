extends Node2D

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func _ready():
	run_intro()
	#NavigationManager.load_data_dictionary("res://data_library/apartment.json")
	#NavigationManager.go_to_scene(0, "IntroSpawn", 1, 10)

func run_intro():
	TransitionScene.transition(3)
	await TransitionScene.on_transition_finished
	
	# Window tap
	var sfx_player = AudioManager.play_sfx("res://assets/audio/SFX/window_knock.mp3", -6)
	if sfx_player:
		await sfx_player.finished
		await get_tree().create_timer(2.0).timeout
		
	# Start the intro dialogue
	DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
	DialogueManager.dialogue_ended.connect(_on_dialogue_finished)

# Accept the argument even if unused
func _on_dialogue_finished(_unused):
	NavigationManager.load_data_dictionary("res://data_library/apartment.json")
	NavigationManager.go_to_scene(0, "IntroSpawn", 1, 10)
