extends Area2D
class_name Door

@export var destination_level_tag: String
@export var destination_door_tag: String
@export var teleport: bool = false
@export var spawn_direction = "up"

@onready var spawn = $Spawn

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		AudioManager.play_sfx("res://assets/audio/door_open.mp3", -6)
		NavigationManager.go_to_level(destination_level_tag, destination_door_tag)
