extends Node2D

#onready var fx_water = load()
func _ready():
	pass # Replace with function body.

func _on_Update_pressed():
	var plants = $Plants.get_children()
	var watered_plant = false
	var counter = 0
	while !watered_plant:
		var plant = plants[randi() % plants.size()]
		if !plant.produced_plant:
			plant.update_plant()
			watered_plant = true
		counter += 1
		if counter == plants.size():
			break
	pass # Replace with function body.
