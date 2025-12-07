extends Room

@onready var desktopScreenLight: PointLight2D = $Overlays/Monitor/MonitorRedLight
@onready var desktopScreen: Sprite2D = $Overlays/Monitor/MonitorRedScreen

func _ready():
	super._ready()
	AudioManager.play_room_audio(name)
	play_cutscene()
	
	desktopScreen.visible = false
	desktopScreenLight.visible = false
	
func _process(delta: float) -> void:
	turn_on_desktop_light()

func play_cutscene():
	if name == "LevelBedroom" and !GlobalState.get_room_state(name, "cutscene1"):
		await CutsceneController.play_cutscene("bedroom_intro")
		GlobalState.set_room_state(name, "cutscene1", true)

# Example of room-specific objects
func turn_on_desktop_light():
	if has_node("Overlays/Monitor/MonitorRedLight") and has_node("Overlays/Monitor/MonitorRedScreen"):
		if GlobalState.get_room_state(name, "blackout"):
			desktopScreen.visible = true
			desktopScreenLight.visible = true
