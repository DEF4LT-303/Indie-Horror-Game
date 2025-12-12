extends Room

@onready var npc: Node = $NPCs/Shade

func _on_shade_move_body_entered(body: Node2D) -> void:
	if body.name == "player":
		npc.start_moving()
