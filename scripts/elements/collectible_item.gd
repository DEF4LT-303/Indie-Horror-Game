extends Node2D

@onready var actionable = $Actionable
@onready var collision = $Actionable/CollisionShape2D
@export var item_name: String = "" 
@export var dialogue_resource: DialogueResource

func _ready():
	if GlobalState.is_item_visible(item_name) == false:
		$".".visible = false
		collision.disabled = true
		
	$AnimatedSprite2D.play("collectible_item")
	
	# Hide if already collected
	if item_name != "" and GlobalState.is_item_collected(item_name):
		queue_free()
		return

	actionable.action_requested.connect(_on_action)

func _on_action(dialogue_resource, dialogue_start):
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start)
	
	if item_name != "":
		GlobalState.mark_item_collected(item_name)
		queue_free()
