extends "res://scenes/plants/Plant.gd"

func _ready():
	plant_name = "Tomato"
	MAX_ANIM_GROW = 3

func _on_Plant_animation_finished():
	._on_Plant_animation_finished()
	pass # Replace with function body.
