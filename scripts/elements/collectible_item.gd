extends Node2D

@onready var actionable = $Actionable
@onready var collision = $Actionable/CollisionShape2D
@export var item_name: String = "" 
@export var dialogue_resource: DialogueResource

var monitoring_pickup := false

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
	
func _process(_delta):
	if monitoring_pickup:
		if GlobalState.is_item_collected(item_name):
			# This triggers immediately when player chooses “Pick up”
			visible = false
			collision.disabled = true

func _on_action(res, dialogue_start):
	DialogueManager.show_dialogue_balloon(res, dialogue_start, [{"item_name": item_name}])
	
	monitoring_pickup = true
	await DialogueManager.dialogue_ended
	monitoring_pickup = false
	
	if GlobalState.is_item_collected(item_name):
		queue_free()
