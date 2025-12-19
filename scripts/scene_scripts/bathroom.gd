extends Room

@onready var npc: CharacterBody2D = $NPCs/Shade
@onready var door: Door = $Doors/Door_Bedroom
#@onready var glitch_effect: CanvasLayer = $GlitchLayer

func _ready() -> void:
	super._ready()
	AudioManager.play_room_audio(name)
	if GlobalState.get_room_state(name, "visited", true):
		npc.visible = false
	
	glitch_effect.visible = false
	GlobalState.connect("item_collected", Callable(self, "_on_item_collected"))

func _on_item_collected(item_name: String) -> void:
	door.locked = true
	if item_name == "letter":
		show_glitch_then_quit(5.0)

func show_glitch_then_quit(duration := 10.0) -> void:
	if not glitch_effect:
		push_warning("No GlitchLayer found")
		return

	# 1. Make glitch layer visible
	glitch_effect.visible = true
	AudioManager.play_sfx("res://assets/audio/SFX/glitch_effect.mp3", -6)

	# 3. Wait for the desired glitch duration
	await DialogueManager.dialogue_ended
	await get_tree().process_frame
	await get_tree().create_timer(duration).timeout
	get_tree().paused = true
	await get_tree().create_timer(3).timeout
	
	# 4. Quit the game
	get_tree().quit()

func _on_shade_move_body_entered(body: Node2D) -> void:
	if body.name == "Player" and npc:
		AudioManager.play_sfx("res://assets/audio/SFX/shade_encounter.mp3", -6)
		npc.start_moving()
