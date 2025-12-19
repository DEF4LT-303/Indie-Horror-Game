extends Room

@onready var desktopScreenLight: PointLight2D = $Overlays/Monitor/MonitorRedLight
@onready var desktopScreen: Sprite2D = $Overlays/Monitor/MonitorRedScreen
@onready var shadeShadow: Sprite2D = $ShadeShadow

func _ready():
	super._ready()
	AudioManager.play_room_audio(name)
	await play_cutscene()
	
	fade_out_shadow()
	
	
func _process(_delta: float) -> void:
	#turn_on_desktop_light()
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
			desktopScreen.visible = true
			desktopScreenLight.visible = true
