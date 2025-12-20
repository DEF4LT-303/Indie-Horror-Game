extends Area2D
class_name Door

@export var destination_level_tag: String
@export var destination_door_tag: String
@export var teleport: bool = false
@export var spawn_direction = "up"
@export var locked: bool = false

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

@onready var spawn = $Spawn

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sfx("res://assets/audio/SFX/door_open.mp3", -6)
		if self.locked:
			DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start)
			return
		NavigationManager.go_to_scene(destination_level_tag, destination_door_tag)
