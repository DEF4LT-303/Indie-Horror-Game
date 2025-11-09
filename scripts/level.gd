extends Node2D


func _ready() -> void:
	NavigationManager.load_data_dictionary("res://data_library/apartment.json")
	NavigationManager.go_to_level(0,"E")
