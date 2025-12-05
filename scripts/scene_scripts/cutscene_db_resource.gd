# CutsceneDB.gd
extends Node
class_name cutscene_db_resource

# Only store the data
static func get_cutscene(name: String) -> Array:
	match name:
		"bedroom_intro":
			return [
				{"type": "wait", "duration": 3.0},
				{"type": "custom", "callback": "play_anim_with_dir", "args": ["left"]},
				{"type": "wait", "duration": 0.8},
				{"type": "custom", "callback": "play_anim_with_dir", "args": ["right"]},
				{"type": "wait", "duration": 0.8},
				{"type": "custom", "callback": "play_anim_with_dir", "args": ["down"]},
				{"type": "wait", "duration": 0.5},
			]
		"some_other_cutscene":
			return [
				{"type": "dialog", "text": "Welcome!"}
			]
		_:
			return []
