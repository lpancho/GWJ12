extends "res://scenes/plants/Plant.gd"

func _ready():
	plant_name = "Chili"
	MAX_ANIM_GROW = 3

func _on_Plant_animation_finished():
	._on_Plant_animation_finished()
	pass # Replace with function body.