@tool
class_name DialogueSystemNode
extends CanvasLayer

var is_active: bool = false
var dialogue_queue: Array[String] = []
var current_index: int = 0

@onready var dialogue_ui: Control = $DialogueUI
@onready var dialogue_label: RichTextLabel = $DialogueUI/PanelContainer/RichTextLabel

func _ready() -> void:
	if Engine.is_editor_hint():
		if get_viewport() is Window:
			get_parent().remove_child(self)
			return
		return
	hide_dialogue()

func _unhandled_input(event: InputEvent) -> void:
	if not is_active:
		return

	# When active, pressing test/interact will go to next line
	if event.is_action_pressed("interact"):
		show_next_line()

func start_dialogue(lines: Array[String]) -> void:
	dialogue_queue = lines
	current_index = 0
	show_dialogue()
	show_next_line()

func show_next_line() -> void:
	if current_index >= dialogue_queue.size():
		hide_dialogue()
		return
	print('Curr idx', current_index)
	print('Diag q', dialogue_queue.size())
	dialogue_label.text = dialogue_queue[current_index]
	current_index += 1

func show_dialogue() -> void:
	is_active = true
	dialogue_ui.visible = true
	dialogue_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	get_tree().paused = true

func hide_dialogue() -> void:
	is_active = false
	dialogue_ui.visible = false
	dialogue_ui.process_mode = Node.PROCESS_MODE_DISABLED
	get_tree().paused = false

	# Clean up
	dialogue_queue.clear()
	current_index = 0
