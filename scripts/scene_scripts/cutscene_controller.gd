extends Node

## A reusable cutscene system that can be triggered from scripts or dialogue mutations
## Supports various actions: wait, move player, camera pan, play animation, etc.
##
## USAGE EXAMPLES:
##
## 1. From Script (after dialogue):
##    await CutsceneController.play_cutscene("intro")
##
## 2. From Dialogue Mutation:
##    In your .dialogue file, add a mutation line:
##    ~ start
##    Hello there!
##    => CutsceneController.play_cutscene_by_name("intro")
##    => END
##
## 3. Custom Cutscene (inline):
##    var custom_cutscene = [
##        {"type": "wait", "duration": 1.0},
##        {"type": "move_player", "position": Vector2(100, 100), "duration": 2.0},
##        {"type": "camera_pan", "position": Vector2(200, 200), "duration": 1.5},
##    ]
##    await CutsceneController.play_cutscene("custom", custom_cutscene)
##
## AVAILABLE ACTION TYPES:
## - "wait": Wait for duration (requires "duration" in seconds)
## - "move_player": Move player to position (requires "position" Vector2, optional "duration", "relative")
## - "camera_pan": Pan camera to position (requires "position" Vector2, optional "duration", "relative")
## - "camera_zoom": Zoom camera (requires "zoom" Vector2, optional "duration")
## - "camera_shake": Shake camera (requires "intensity" float, "duration" float)
## - "play_animation": Play animation on player/node (requires "animation" string, optional "node", "wait")
## - "play_sound": Play sound effect (requires "sound" path string, optional "volume")
## - "set_event": Set global event flag (requires "event" string, "value" bool)
## - "custom": Execute custom callback (requires "callback" Callable or string, optional "args")

signal cutscene_started(cutscene_name: String)
signal cutscene_finished(cutscene_name: String)
signal cutscene_action_completed(action_type: String)

var is_playing: bool = false
var current_cutscene_name: String = ""

# Cache references
var player: CharacterBody2D = null
var camera: Camera2D = null

func _ready() -> void:
	# Find player when ready
	call_deferred("_find_player")

func _find_player() -> void:
	var attempts = 0
	while not player and attempts < 120:  # try for 120 frames (~2 seconds)
		var nodes = get_tree().get_nodes_in_group("player")
		if nodes.size() > 0:
			player = nodes[0]
			break
		attempts += 1
		await get_tree().process_frame

	if not player:
		#push_error("Player not found for cutscene!")
		return

	# Find camera if needed
	camera = player.get_node_or_null("Camera2D")
	if not camera:
		var cameras = get_tree().get_nodes_in_group("camera")
		if cameras.size() > 0:
			camera = cameras[0]


## Start a cutscene by name (from a predefined dictionary)
## You can also pass a custom cutscene array directly
func play_cutscene(cutscene_name: String, custom_cutscene: Array = []) -> void:
	if is_playing:
		push_warning("Cutscene already playing: " + current_cutscene_name)
		return
	
	var cutscene_data: Array = custom_cutscene
	if cutscene_data.is_empty():
		cutscene_data = get_cutscene_data(cutscene_name)
	
	if cutscene_data.is_empty():
		push_error("Cutscene not found: " + cutscene_name)
		return
	
	print("Playing  cutscene: ", cutscene_name)
	is_playing = true
	current_cutscene_name = cutscene_name
	cutscene_started.emit(cutscene_name)
	
	# Disable player movement
	GlobalState.player_can_move = false
	
	# Ensure we have player reference
	if not player:
		_find_player()
	
	# Execute cutscene actions
	await _execute_cutscene(cutscene_data)
	
	# Re-enable player movement
	GlobalState.player_can_move = true
	
	is_playing = false
	var finished_name = current_cutscene_name
	current_cutscene_name = ""
	cutscene_finished.emit(finished_name)

## Execute a sequence of cutscene actions
func _execute_cutscene(actions: Array) -> void:
	for action in actions:
		if not is_playing:  # Allow early exit
			break
		
		var action_type = action.get("type", "")
		match action_type:
			"wait":
				await _action_wait(action)
			"move_player":
				await _action_move_player(action)
			"camera_pan":
				await _action_camera_pan(action)
			"camera_zoom":
				await _action_camera_zoom(action)
			"camera_shake":
				await _action_camera_shake(action)
			"play_animation":
				await _action_play_animation(action)
			"play_sound":
				_action_play_sound(action)
			"set_event":
				_action_set_event(action)
			"custom":
				await _action_custom(action)
			_:
				push_warning("Unknown cutscene action type: " + str(action_type))
		
		cutscene_action_completed.emit(action_type)

## Action: Wait for a duration
func _action_wait(action: Dictionary) -> void:
	var duration = action.get("duration", 1.0)
	await get_tree().create_timer(duration).timeout

## Action: Move player to a position
func _action_move_player(action: Dictionary) -> void:
	if not player:
		push_warning("Player not found for move_player action")
		return
	
	var target_pos = action.get("position", Vector2.ZERO)
	var duration = action.get("duration", 1.0)
	var relative = action.get("relative", false)
	
	var start_pos = player.global_position
	var end_pos = target_pos if not relative else start_pos + target_pos
	
	var tween = create_tween()
	tween.tween_property(player, "global_position", end_pos, duration)
	await tween.finished

## Action: Pan camera to a position
func _action_camera_pan(action: Dictionary) -> void:
	if not camera:
		push_warning("Camera not found for camera_pan action")
		return
	
	var target_pos = action.get("position", Vector2.ZERO)
	var duration = action.get("duration", 1.0)
	var relative = action.get("relative", false)
	
	var start_pos = camera.global_position
	var end_pos = target_pos if not relative else start_pos + target_pos
	
	var tween = create_tween()
	tween.tween_property(camera, "global_position", end_pos, duration)
	await tween.finished

## Action: Zoom camera
func _action_camera_zoom(action: Dictionary) -> void:
	if not camera:
		push_warning("Camera not found for camera_zoom action")
		return
	
	var target_zoom = action.get("zoom", Vector2.ONE)
	var duration = action.get("duration", 1.0)
	
	var start_zoom = camera.zoom
	var tween = create_tween()
	tween.tween_property(camera, "zoom", target_zoom, duration)
	await tween.finished

## Action: Camera shake
func _action_camera_shake(action: Dictionary) -> void:
	if not camera:
		push_warning("Camera not found for camera_shake action")
		return
	
	var intensity = action.get("intensity", 5.0)
	var duration = action.get("duration", 0.5)
	var original_pos = camera.global_position
	
	var shake_tween = create_tween()
	shake_tween.set_loops(int(duration * 60))  # 60 shakes per second
	
	for i in range(int(duration * 60)):
		var offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		camera.global_position = original_pos + offset
		await get_tree().process_frame
	
	camera.global_position = original_pos

## Action: Play animation on player or specified node
func _action_play_animation(action: Dictionary) -> void:
	var target_node = action.get("node", null)
	var anim_name = action.get("animation", "")
	var wait_for_completion = action.get("wait", true)
	
	if not target_node:
		target_node = player
	
	if not is_instance_valid(target_node):
		push_warning("Invalid node for play_animation action")
		return
	
	var anim_sprite = target_node.get_node_or_null("AnimatedSprite2D")
	if not anim_sprite:
		push_warning("AnimatedSprite2D not found on target node")
		return
	
	anim_sprite.play(anim_name)
	
	if wait_for_completion:
		await anim_sprite.animation_finished

## Action: Play sound effect
func _action_play_sound(action: Dictionary) -> void:
	var sound_path = action.get("sound", "")
	var volume = action.get("volume", 0.0)
	
	if sound_path.is_empty():
		push_warning("No sound path specified for play_sound action")
		return
	
	if AudioManager and AudioManager.has_method("play_sfx"):
		AudioManager.play_sfx(sound_path, volume)
	#else:
		## Fallback: create AudioStreamPlayer
		#var audio_player = AudioStreamPlayer.new()
		#var stream = load(sound_path)
		#if stream:
			#audio_player.stream = stream
			#audio_player.volume_db = volume
			#add_child(audio_player)
			#audio_player.play()
			#await audio_player.finished
			#audio_player.queue_free()

## Action: Set a global event flag
func _action_set_event(action: Dictionary) -> void:
	var event_name = action.get("event", "")
	var value = action.get("value", true)
	
	if event_name.is_empty():
		push_warning("No event name specified for set_event action")
		return
	
	GlobalState.events[event_name] = value

## Action: Custom callback function
func _action_custom(action: Dictionary) -> void:
	var callback = action.get("callback", null)
	var args = action.get("args", [])

	if callback == null:
		push_warning("No callback specified for custom action")
		return

	# If it's already a Callable, just call it
	if callback is Callable:
		if args.empty():
			await callback.call() if callback.is_valid() else null
		else:
			await callback.callv(args) if callback.is_valid() else null

	# If it's a String, call it on the player
	elif callback is String:
		if player and player.has_method(callback):
			await player.callv(callback, args)
		else:
			push_warning("Callback string '" + callback + "' not found on player")


## Stop the current cutscene
func stop_cutscene() -> void:
	if is_playing:
		is_playing = false
		GlobalState.player_can_move = true
		cutscene_finished.emit(current_cutscene_name)
		current_cutscene_name = ""

## Get predefined cutscene data by name
## You can extend this with your own cutscenes
func get_cutscene_data(cutscene_name: String) -> Array:
	# Get cutscene data from the centralized database
	return CutsceneDB.get_cutscene(cutscene_name)
	

## Helper function to create a cutscene array (for use in dialogue mutations)
## Example: CutsceneController.create_cutscene([{"type": "wait", "duration": 2.0}])
static func create_cutscene(actions: Array) -> Array:
	return actions

## Convenience method for calling from dialogue mutations
## Usage in dialogue: CutsceneController.play_cutscene_by_name("intro")
func play_cutscene_by_name(cutscene_name: String) -> void:
	await play_cutscene(cutscene_name)
