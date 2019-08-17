extends Node2D

onready var chain_text_scn = load("res://scenes/chain_msg_popup/Chain.tscn")
onready var fx_water_scn = load("res://scenes/fxs/WaterEffect.tscn")
onready var raining_text = $RainingText
onready var stage_timer = $DayNightTimeContainer/ColorRect/StageTimer
onready var date_time_timer = $DayNightTimeContainer/DayNightTimer
onready var time_transition = $TimeTransition
onready var cloud_transition = $CloudTransition
onready var monsters = $Monsters
onready var plants = $Plants
onready var harvests = $Havests

var stage_time_now = 0
var stage_time_start = 0
var STAGE_TIMER = 61000
enum time_scene {MORNING, EVENING, CLEANING}
var current_time_scene = time_scene.MORNING
var is_timer_ready = true
var prev_second_change_time = 0
var total_tomato = 0

func _ready():
	set_process(false)
	raining_text.current_time_scene = current_time_scene
	raining_text.enable_process(false)
	raining_text.connect("water_plants", self, "_on_WaterPlants")
	raining_text.connect("attack_enemies", self, "_on_AttackEnemies")
	
	# connect plants update harvest count
	for plant in plants.get_children():
		plant.connect("update_plant_harvest", self, "_on_Update_PlantHarvest")
	
	cloud_transition.connect("cloud_transition_played", self, "_on_CloudTransition_Played")
	cloud_transition.setup_requirements(1)
	pass # Replace with function body.

func _process(delta):
	if is_timer_ready:
		display_stage_time()
	elif !is_timer_ready and current_time_scene == time_scene.MORNING:
		# show animation in the screen - showing defend time
		raining_text.enable_process(false)
		for plant in $Plants.get_children():
			plant.enable_process(false)
		current_time_scene = time_scene.CLEANING
		time_transition.play_time_transition(current_time_scene)
		# play animation for evening stage
		pass
	elif !is_timer_ready and current_time_scene == time_scene.EVENING:
		print("TO MORNING")
		pass

func display_stage_time():
	stage_time_now = OS.get_ticks_msec()
	var elapsed = STAGE_TIMER - (stage_time_now - stage_time_start)
#	prints(stage_time_now, stage_time_start, elapsed, elapsed % 1000, elapsed / 1000 % 60, elapsed / 1000 / 60)
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	var seconds = clamp(elapsed / 1000 % 60, 0, 59)
	var minutes = clamp(elapsed / 1000 / 60, 0, 59)
	var str_elapsed = "%02d : %02d" % [minutes, seconds]
	
	if minutes == 1:
		if current_time_scene == time_scene.MORNING:
			date_time_timer.frame = 0
		else:
			date_time_timer.frame = 12
	elif seconds % 5 == 0 and seconds != prev_second_change_time:
		date_time_timer.frame += 1
		prev_second_change_time = seconds
	
#	print(str_elapsed)
	if milliseconds == 0 and seconds == 0 and minutes == 0:
		is_timer_ready = false
		print("stage timer reached to 0")
	else:
		stage_timer.text = str_elapsed

func _on_WaterPlants(start_pos, chain):
	var plants = $Plants.get_children()
	var counter = 0
	var current_chain_count = 0
	var selected_plant

	create_chain_text(start_pos, chain)
	
	var selected_plants = get_plant_to_water(chain)
	for plant in selected_plants:
		var fx_water = fx_water_scn.instance()
		fx_water.position = start_pos
		add_child(fx_water)
		fx_water.fx_animate(start_pos, plant)

func _on_AttackEnemies(start_pos, chain, object):
	if monsters.get_child_count() != 0:
		create_chain_text(start_pos, chain)
		# currently, we will only use one monster per stage
		var monster = monsters.get_children()[0]
		var weapon = load(object).instance()
		weapon.position = start_pos
		weapon.show_sword_base_on_chain(chain)
		weapon.connect("damage_monster", self, "_on_DamageMonster")
		add_child(weapon)
		weapon.move(start_pos, monster.position)
	pass

func create_chain_text(_position, count):
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

func _on_TimeTransition_start_stage(_current_time_scene):
	if _current_time_scene == time_scene.MORNING:
		stage_time_start = OS.get_ticks_msec()
		is_timer_ready = true
		prev_second_change_time = 0
		raining_text.enable_process(true)
		set_process(true)
	elif _current_time_scene == time_scene.EVENING:
		
		var bat = load("res://scenes/monsters/Bat.tscn").instance()
		bat.position = Vector2(365, -95)
		bat.playing = false
		bat.connect("attack_crop", self, "_on_AttackCrop")
		bat.connect("monster_dead", self, "_on_MonsterDead")
		
		monsters.add_child(bat)
		bat.get_node("Anim").play("approach")
		
		raining_text.current_time_scene = time_scene.EVENING
		stage_time_start = OS.get_ticks_msec()
		is_timer_ready = true
		prev_second_change_time = 0
		raining_text.enable_process(true)
		set_process(true)
	elif _current_time_scene == time_scene.CLEANING:
		remove_texts_in_screen()
		stage_timer.text = "01 : 01"
		raining_text.clean()
		is_timer_ready = false
		time_transition.play_time_transition(time_scene.EVENING)
	pass # Replace with function body.

func _on_AttackCrop(damage):
	var plants_indexes = []
	var count = 0
	randomize()
	while count != damage:
		var index = randi() % plants.get_child_count()
		if !plants_indexes.has(index):
			plants_indexes.append(index)
			count += 1
#
#	for i in plants_indexes:
#		var plant = plants.get_children()[i]
#		plant.monster_get_plant($monsters[0])
	
	
	var plant = plants.get_child_count()
	for plant in harvests.get_children():
		var harvest_count = int(plant.get_node("Sprite/Count").text)
		if harvest_count > 0:
			harvest_count -= damage
			plant.get_node("Sprite/Count").text = str(harvest_count)

func _on_MonsterDead():
	print("stage completed.... transition to next stage")
	pass

func _on_DamageMonster(damage):
	if monsters.get_child_count() != 0:
		var monster = monsters.get_children()[0]
		monster.received_attack(damage)
	pass

func _on_Update_PlantHarvest(plant_name):
	for plant in harvests.get_children():
		if plant.name == plant_name:
			total_tomato += 1
			plant.get_node("Sprite/Count").text = str(total_tomato)

func _on_CloudTransition_Played():
	time_transition.play_time_transition(current_time_scene)