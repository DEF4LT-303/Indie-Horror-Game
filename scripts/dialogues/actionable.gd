extends Area2D

signal action_requested

@export var dialogue_resource: DialogueResource
@export var dialogue_start: String = "start"

func action():
	action_requested.emit(dialogue_resource, dialogue_start)
