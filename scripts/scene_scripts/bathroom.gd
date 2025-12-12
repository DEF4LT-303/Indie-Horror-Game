extends Room

@onready var npc: CharacterBody2D = $NPCs/Shade

func _ready() -> void:
	super._ready()
	AudioManager.play_room_audio(name)
	if GlobalState.get_room_state(name, "visited", true):
		npc.visible = false

func _on_shade_move_body_entered(body: Node2D) -> void:
	if body.name == "Player" and npc:
		AudioManager.play_sfx("res://assets/audio/SFX/shade_encounter.mp3", -6)
		npc.start_moving()
