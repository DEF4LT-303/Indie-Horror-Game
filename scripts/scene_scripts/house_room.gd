extends Room

# ------------------------------------
# LIGHTING PRESETS (tweak as you like)
# ------------------------------------
const COLOR_NORMAL      := Color(1, 1, 1, 1)
const COLOR_DARK_ROOM   := Color(0.128, 0.128, 0.249, 1.0)   # Paper Lily style
const COLOR_EMERGENCY   := Color(0.45, 0.05, 0.05, 1.0)   # Desaturated danger red
const COLOR_BLACKOUT    := Color(0, 0, 0, 1)

@onready var modulate_node: CanvasModulate = $CanvasModulate

var flicker_tween: Tween = null

#func _enter_tree() -> void:
	#var modulate_node = get_node_or_null("CanvasModulate")
	#if modulate_node:
		#apply_initial_lighting(modulate_node)

	
func apply_initial_lighting() -> void:
	var room_name = self.name

	if GlobalState.events.get("emergency_mode", false) \
		or GlobalState.get_room_state(room_name, "emergency"):
		modulate_node.color = COLOR_EMERGENCY

	elif GlobalState.events.get("blackout", false) \
		or GlobalState.get_room_state(room_name, "blackout"):
		modulate_node.color = COLOR_BLACKOUT

	elif GlobalState.get_room_state(room_name, "dark"):
		modulate_node.color = COLOR_DARK_ROOM

	else:
		modulate_node.color = COLOR_NORMAL



func _ready() -> void:
	super._ready()
	apply_state_lighting()


# -------------------------------------------------------------
# AUTO-LIGHTING BASED ON GLOBAL FLAGS (customize as needed)
# -------------------------------------------------------------
func apply_state_lighting() -> void:
	var room_name = self.name

	if GlobalState.events.get("emergency_mode", false) \
			or GlobalState.get_room_state(room_name, "emergency"):
		fade_to_emergency()
		start_emergency_flicker()

	elif GlobalState.events.get("blackout", false) \
			or GlobalState.get_room_state(room_name, "blackout"):
		fade_to_blackout()

	elif GlobalState.get_room_state(room_name, "dark"):
		print(room_name)
		fade_to_dark_room()

	else:
		fade_to_normal()
		stop_flicker()


# -------------------------------------------------------------
# PUBLIC LIGHTING CONTROLS
# -------------------------------------------------------------
func fade_to_normal(duration := 0.8) -> void:
	_fade_to(COLOR_NORMAL, duration)


func fade_to_dark_room(duration := 1.2) -> void:
	_fade_to(COLOR_DARK_ROOM, duration)


func fade_to_emergency(duration := 0.8) -> void:
	_fade_to(COLOR_EMERGENCY, duration)


func fade_to_blackout(duration := 0.7) -> void:
	_fade_to(COLOR_BLACKOUT, duration)


# -------------------------------------------------------------
# FLICKER SYSTEM (Paper Lily emergency vibe)
# -------------------------------------------------------------
func start_emergency_flicker(strength := 0.07, speed := 0.12) -> void:
	stop_flicker()
	flicker_tween = create_tween().set_loops()

	var brighter = Color(
		COLOR_EMERGENCY.r + strength,
		COLOR_EMERGENCY.g + strength * 0.2,
		COLOR_EMERGENCY.b + strength * 0.2
	)
	var darker = Color(
		COLOR_EMERGENCY.r - strength,
		COLOR_EMERGENCY.g - strength * 0.2,
		COLOR_EMERGENCY.b - strength * 0.2
	)

	flicker_tween.tween_property(modulate_node, "color", brighter, speed)
	flicker_tween.tween_property(modulate_node, "color", darker, speed)


func stop_flicker() -> void:
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	flicker_tween = null


# -------------------------------------------------------------
# INTERNAL FADE FUNCTION
# -------------------------------------------------------------
func _fade_to(target: Color, duration: float) -> void:
	stop_flicker()
	var t := create_tween()
	t.tween_property(modulate_node, "color", target, duration)
