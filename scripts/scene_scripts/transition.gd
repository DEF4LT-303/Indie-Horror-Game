extends Node

signal on_transition_finished

@onready var color_rect = $ColorRect
@onready var animation_player = $AnimationPlayer

var _next_fade_in_time := 1.0

func _ready() -> void:
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	
func _on_animation_finished(anim_name) -> void:
	if anim_name == "fade_to_black":
		on_transition_finished.emit()

		# Apply fade-in timing
		animation_player.speed_scale = 1.0 / _next_fade_in_time
		animation_player.play("fade_to_normal")
	elif anim_name == "fade_to_normal":
		color_rect.visible = false

	
func transition(fade_out_time := 1.0, fade_in_time := 1.0) -> void:
	color_rect.visible = true

	# Set speed for fade-to-black (assume base animation is 1 sec)
	animation_player.speed_scale = 1.0 / fade_out_time
	animation_player.play("fade_to_black")

	# Store fade_in_time for later use
	_next_fade_in_time = fade_in_time
