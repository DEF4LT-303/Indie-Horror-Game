extends Node

@onready var bgm_player: AudioStreamPlayer = AudioStreamPlayer.new()
@onready var ambient_player: AudioStreamPlayer = AudioStreamPlayer.new()

var current_room: String = ""
var default_bgm: AudioStream = null
var default_ambient: AudioStream = null

func _ready():
	add_child(bgm_player)
	add_child(ambient_player)
	bgm_player.volume_db = -40
	ambient_player.volume_db = -40

	# Connect to GlobalState
	if Engine.has_singleton("GlobalState"):
		GlobalState.connect("state_changed", Callable(self, "_on_room_changed"))

# ----------------------
# PUBLIC METHODS
# ----------------------

func play_room_audio(room_name: String):
	current_room = room_name

	var bgm_path = GlobalState.rooms[room_name].get("bgm_override")
	var amb_path = GlobalState.rooms[room_name].get("ambient_override")

	var bgm_to_play: AudioStream = load(bgm_path) if bgm_path != null else null
	var amb_to_play: AudioStream = load(amb_path) if amb_path != null else null

	_handle_audio_change(bgm_player, bgm_to_play, -20)
	_handle_audio_change(ambient_player, amb_to_play, -15)


func _handle_audio_change(player: AudioStreamPlayer, new_stream: AudioStream, target_volume_db: float):
	if new_stream == null:
		_fade_out_and_stop(player)
	else:
		_crossfade(player, new_stream, target_volume_db)

func _fade_out_and_stop(player: AudioStreamPlayer):
	if player.stream == null:
		return

	var t = create_tween()
	t.tween_property(player, "volume_db", -40, 0.4)
	t.tween_callback(func():
		player.stop()
		player.stream = null
	)


func _on_room_changed(changed_room_name: String):
	if changed_room_name == current_room:
		play_room_audio(current_room)

# ----------------------
# CROSSFADE UTILITY
# ----------------------

func _crossfade(player: AudioStreamPlayer, new_stream: AudioStream, target_volume_db: float = 0):
	if new_stream == null or player.stream == new_stream:
		return

	var t = create_tween()
	t.tween_property(player, "volume_db", -40, 0.4)
	t.tween_callback(func():
		player.stream = new_stream
		player.play()
	)
	t.tween_property(player, "volume_db", target_volume_db, 0.4)
	
	# ----------------------
# SFX PLAYER POOL
# ----------------------

var sfx_pool: Array[AudioStreamPlayer] = []
const MAX_SFX = 16   # prevents infinite build-up

func play_sfx(path: String, volume_db: float = 0.0) -> AudioStreamPlayer:
	var stream: AudioStream = load(path)
	if stream == null:
		push_warning("Invalid SFX path: " + path)
		return null

	var player := _get_sfx_player()
	player.stream = stream
	player.volume_db = volume_db
	player.play()

	# Use a lambda to recycle the player when finished
	player.finished.connect(func(p=player):
		_recycle_sfx_player(p)
	)

	return player


func _get_sfx_player() -> AudioStreamPlayer:
	# Reuse available player from pool
	for p in sfx_pool:
		if not p.playing:
			return p

	# Create new player if pool is not full
	if sfx_pool.size() < MAX_SFX:
		var p = AudioStreamPlayer.new()
		add_child(p)
		sfx_pool.append(p)
		return p

	# Fallback: reuse first player in pool if max reached
	return sfx_pool[0]


func _recycle_sfx_player(player: AudioStreamPlayer) -> void:
	if player.playing:
		player.stop()
	player.stream = null
