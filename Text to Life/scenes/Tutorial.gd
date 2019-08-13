extends Node2D

onready var chain_text_scn = load("res://scenes/chain_msg_popup/Chain.tscn")
onready var fx_water_scn = load("res://scenes/fxs/WaterEffect.tscn")
onready var raining_text = $RainingText
onready var stage_timer = $ColorRect/StageTimer

var stage_time_now = 0
var stage_time_start = 0
var STAGE_TIMER = 60000
enum time_scene {MORNING, EVENING}
var current_time_scene = time_scene.MORNING
var is_timer_ready = true

func _ready():
	set_process(false)
	raining_text.enable_process(false)
	raining_text.connect("water_plants", self, "_on_WaterPlants")
	$TimeTransition.play_time_transition(current_time_scene)
	pass # Replace with function body.

func _process(delta):
	if is_timer_ready:
		display_stage_time()
	elif !is_timer_ready and current_time_scene == time_scene.MORNING:
		# show animation in the screen - showing defend time
		current_time_scene = time_scene.EVENING
		$TimeTransition.play_time_transition(current_time_scene)
		# play animation for evening stage
		pass

func display_stage_time():
	stage_time_now = OS.get_ticks_msec()
	var elapsed = STAGE_TIMER - (stage_time_now - stage_time_start)
	prints(stage_time_now, stage_time_start, elapsed, elapsed % 1000, elapsed / 1000 % 60, elapsed / 1000 / 60)
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	var seconds = clamp(elapsed / 1000 % 60, 0, 59)
	var minutes = clamp(elapsed / 1000 / 60, 0, 59)
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
#	print(str_elapsed)
	if milliseconds == 0 and seconds == 0 and minutes == 0:
		is_timer_ready = false
		print("stage timer reached to 0")
	else:
		stage_timer.text = str_elapsed

func _on_WaterPlants(start_pos, chain, rect_size):
	var plants = $Plants.get_children()
	var counter = 0
	var current_chain_count = 0
	var selected_plant
	
	if chain == 0:
		chain = 1
	create_chain_text(start_pos, rect_size, chain)
	
	var selected_plants = get_plant_to_water(chain)
	for plant in selected_plants:
		var fx_water = fx_water_scn.instance()
		fx_water.position = start_pos
		add_child(fx_water)
		fx_water.fx_animate(start_pos, plant)

func create_chain_text(_position, rect_size, count):
	var chain_text_offset = Vector2(50, -4)
	var chain_text = chain_text_scn.instance()
	add_child(chain_text)
	var pos = _position + chain_text_offset
	chain_text.initialize(pos, count)

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

func remove_texts_in_screen():
	var text_nodes = get_tree().get_nodes_in_group("TEXTS")
	for node in text_nodes:
		node.queue_free()

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

func _on_TimeTransition_start_stage():
	remove_texts_in_screen()
#	yield(get_tree().create_timer(1), "timeout")
	set_process(true)
	raining_text.enable_process(true)
	stage_time_start = OS.get_ticks_msec()
	pass # Replace with function body.
