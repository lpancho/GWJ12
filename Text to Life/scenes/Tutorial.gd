extends Node2D

onready var fx_water_scn = load("res://scenes/fxs/WaterEffect.tscn")
onready var raining_text = $RainingText
func _ready():
	raining_text.connect("water_plants", self, "_on_WaterPlants")
	pass # Replace with function body.

func _on_WaterPlants(start_pos, chain):
	var plants = $Plants.get_children()
	var counter = 0
	var current_chain_count = 0
	var selected_plant
	
	if chain == 0:
		chain = 1
	
	var selected_plants = get_plant_to_water(chain)
	for plant in selected_plants:
		var fx_water = fx_water_scn.instance()
		fx_water.position = start_pos
		add_child(fx_water)
		fx_water.fx_animate(start_pos, plant)

func update_plant(selected_plant):
	selected_plant.update_plant()

func get_plant_to_water(count):
	var selected_plants = []
	var selected_count = 0
	var plants = $Plants.get_children()
	for plant in plants:
		if !plant.produced_plant:
			selected_plants.append(plant)
			selected_count += 1
			if selected_count == count:
				break
	return selected_plants

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
