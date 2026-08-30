extends Room

@onready var monitor_screen: Node2D = $Overlays/Monitor
@onready var shadeShadow: Sprite2D = $ShadeShadow

func _ready():
	super._ready()
	AudioManager.play_room_audio(name)
	monitor_screen.visible = false
	await play_cutscene()
	
	fade_out_shadow()
	start_glitch_sequence()
	
func _process(_delta: float) -> void:
	pass

func play_cutscene():
	if name == "LevelBedroom" and !GlobalState.get_room_state(name, "intro_cutscene"):
		await CutsceneController.play_cutscene("bedroom_intro")
		GlobalState.set_room_state(name, "intro_cutscene", true)

func fade_out_shadow():
	var tween := create_tween()
	tween.tween_property(shadeShadow, "modulate:a", 0.0, 2)
	tween.tween_callback(func(): shadeShadow.visible = false)
	
# Example of room-specific objects
func turn_on_desktop_light():
	if has_node("Overlays/Monitor/MonitorRedLight") and has_node("Overlays/Monitor/MonitorRedScreen"):
		if GlobalState.get_room_state(name, "blackout"):
			monitor_screen.visible = true

func start_glitch_sequence() -> void:
	await get_tree().create_timer(5.0).timeout
	await glitch_event()


func glitch_event() -> void:
	GlobalState.set_room_state(name, "blackout", true)
	#AudioManager.play_sfx("res://assets/audio/SFX/glitch_effect.mp3", -6)

	if has_node("GlitchLayer"):
		$GlitchLayer.visible = true

	monitor_screen.visible = true

	await get_tree().create_timer(0.2).timeout

	monitor_screen.visible = false

	if has_node("GlitchLayer"):
		$GlitchLayer.visible = false

	GlobalState.set_room_state(name, "blackout", false)
