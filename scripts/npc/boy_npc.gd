extends CharacterBody2D

@onready var interaction_area: Area2D = $InteractionArea

func _ready() -> void:
	interaction_area.body_entered.connect(_on_body_entered)
	interaction_area.body_exited.connect(_on_body_exited)

var player_in_range: bool = false

func _on_body_entered(body: Node) -> void:
	if body is Player:
		player_in_range = true
		# Optionally show "Press E" prompt here

func _on_body_exited(body: Node) -> void:
	if body is Player:
		player_in_range = false
		# Optionally hide "Press E" prompt here

func _process(_delta: float) -> void:
	if player_in_range and Input.is_action_just_pressed("interact"):
		interact()

func interact() -> void:
	DialogueSystem.start_dialogue([
		"Hey...",
		"What are you doing here?",
        "Be careful."
	])
