extends Node2D

# plants
onready var tomato_scn = load("res://scenes/plants/Tomato.tscn")
onready var cabbage_scn = load("res://scenes/plants/Cabbage.tscn")
onready var chili_scn = load("res://scenes/plants/Chili.tscn")
onready var eggplant_scn = load("res://scenes/plants/Eggplant.tscn")

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
onready var monster_respawn_timer = $MonsterRespawnTimer
onready var anim = $Anim
onready var pause_container = $Paused

var stage_time_now = 0
var stage_time_start = 0
var stage_time_pause_now = 0
var stage_time_pause_start = 0
var pause_time_value = 0
var elapsed_time = 0
var STAGE_TIMER = 61000
var elapsed
enum time_scene {MORNING, EVENING, MORNING_CLEANING, EVENING_CLEANING}
var current_time_scene = time_scene.MORNING
var is_timer_ready = true
var prev_second_change_time = 0

func _ready():
	set_process(false)
	raining_text.current_time_scene = current_time_scene
	raining_text.enable_process(false)
	raining_text.connect("water_plants", self, "_on_WaterPlants")
	raining_text.connect("attack_enemies", self, "_on_AttackEnemies")
	raining_text.connect("game_pause", self, "_on_GamePaused")

	cloud_transition.connect("cloud_transition_played", self, "_on_CloudTransition_Played")
	cloud_transition.setup_requirements(globals.current_stage)
	
	for harvest in harvests.get_children():
		var plant_name = harvest.name
		var updated_count = 0
		if plant_name == "Tomato":
			updated_count = globals.total_tomato
		elif plant_name == "Cabbage":
			updated_count = globals.total_cabbage
		elif plant_name == "Chili":
			updated_count = globals.total_chili
		elif plant_name == "Eggplant":
			updated_count = globals.total_eggplant
		harvest.get_node("Sprite/Count").text = str(updated_count)
	pass # Replace with function body.

func _process(delta):
	if is_timer_ready:
		display_stage_time()
	elif !is_timer_ready and current_time_scene == time_scene.MORNING:
		# show animation in the screen - showing defend time
		raining_text.enable_process(false)
		for container in plants.get_children():
			if container.get_child_count() == 1:
				container.get_child(0).enable_process(false)
		current_time_scene = time_scene.MORNING_CLEANING
		time_transition.play_time_transition(current_time_scene)
		# play animation for evening stage
		pass
	elif !is_timer_ready and current_time_scene == time_scene.EVENING:
		raining_text.enable_process(false)
		for container in plants.get_children():
			if container.get_child_count() == 1:
				container.remove_child(container.get_child(0))
		monster_respawn_timer.stop()
		for monster in monsters.get_children():
			monster.stop_attack()
			
		current_time_scene = time_scene.EVENING_CLEANING
		time_transition.play_time_transition(current_time_scene)
		pass

func display_stage_time():
	stage_time_now = OS.get_ticks_msec()
	
	elapsed = STAGE_TIMER - (stage_time_now - stage_time_start - pause_time_value)
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
#		print(current_time_scene)
		print("stage timer reached to 0")
	else:
		stage_timer.text = str_elapsed

func _on_WaterPlants(start_pos, chain):
	create_chain_text(start_pos, chain)
#	print("chain: ", chain)
	var selected_containers = get_plant_containers_to_water(chain)
#	prints("selected_containers: ", selected_containers)
	for container in selected_containers:
		var fx_water = fx_water_scn.instance()
		fx_water.position = start_pos
		add_child(fx_water)
		var plant = container.get_child(0)
		fx_water.fx_animate(start_pos, container.position, plant)

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
 
func get_plant_containers_to_water(count):
	var selected_containers = []
	var selected_count = 0
	var plant_containers = plants.get_children()
	for container in plant_containers:
		if container.get_child_count() == 1:
			var plant = container.get_child(0)
			if !plant.produced_plant:
				selected_containers.append(container)
				selected_count += 1
		else:
			var plant = tomato_scn.instance()
			plant.connect("update_plant_harvest", self, "_on_Update_PlantHarvest")
			container.add_child(plant)
			selected_containers.append(container)
			selected_count += 1
			
		if selected_count == count:
			break
	
	# if plants to upgrade is > 0
	# this means that we have reaced the last crop
	# we will now upgrade it
	# we will only upgrade the plant that is not the same of the
	# last plant 
	var plants_to_upgrade = count - selected_count
	var upgraded_plants_count = 0
	if plants_to_upgrade > 0:
		for container in plant_containers:
			var plant = container.get_child(0)
			if plant.plant_name == plant_containers.back().get_child(0).plant_name:
				create_new_plant(plant)
				upgraded_plants_count += 1
				if upgraded_plants_count == plants_to_upgrade:
					break 
	return selected_containers

func create_new_plant(old_plant):
	var new_plant = null
	if old_plant.name == "Tomato":
		new_plant = cabbage_scn.instance()
	elif old_plant.name == "Cabbage":
		new_plant = chili_scn.instance()
	elif old_plant.name == "Chili":
		new_plant = eggplant_scn.instance()
	
	if new_plant != null:
		new_plant.connect("update_plant_harvest", self, "_on_Update_PlantHarvest")
		old_plant.get_parent().add_child(new_plant)
		
		old_plant.set_process(false)
		old_plant.queue_free()
	pass

func remove_texts_in_screen():
	var text_nodes = get_tree().get_nodes_in_group("TEXTS")
	for node in text_nodes:
		node.remove_text()
		yield(get_tree().create_timer(0.1),"timeout")

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
		current_time_scene = time_scene.MORNING
		stage_time_start = OS.get_ticks_msec()
		is_timer_ready = true
		prev_second_change_time = 0
		raining_text.enable_process(true)
		set_process(true)
		anim.play_backwards("night")
	elif _current_time_scene == time_scene.EVENING:
		create_new_monster(globals.current_stage)
		current_time_scene = time_scene.EVENING
		raining_text.current_time_scene = time_scene.EVENING
		stage_time_start = OS.get_ticks_msec()
		is_timer_ready = true
		prev_second_change_time = 0
		raining_text.enable_process(true)
		set_process(true)
		anim.play("night")
	elif _current_time_scene == time_scene.MORNING_CLEANING:
		remove_texts_in_screen()
		stage_timer.text = "01 : 01"
		raining_text.clean()
		is_timer_ready = false
		time_transition.play_time_transition(time_scene.EVENING)
	elif _current_time_scene == time_scene.EVENING_CLEANING:
		
		remove_monster_in_screen()
		remove_texts_in_screen()
		stage_timer.text = "01 : 01"
		raining_text.clean()
		is_timer_ready = false
		
		set_process(false)
		current_time_scene = time_scene.MORNING
		raining_text.current_time_scene = current_time_scene
		raining_text.enable_process(false)
		
		
		cloud_transition.is_input_disable = false
		if globals.check_if_requirements_met():
			anim.play_backwards("night")
			if !globals.check_if_last_stage():
				globals.update_current_stage()
				cloud_transition.setup_requirements(globals.current_stage)
			else:
				cloud_transition.show_ending()
		else:
			cloud_transition.show_did_not_met()
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
	
	for plant in harvests.get_children():
		var harvest_count = int(plant.get_node("Sprite/Count").text)
		if harvest_count > 0:
			harvest_count -= damage
			harvest_count = clamp(harvest_count, 0, 999)
			
			if plant.name == "Tomato":
				globals.total_tomato = harvest_count
			if plant.name == "Cabbage":
				globals.total_cabbage = harvest_count
			if plant.name == "Chili":
				globals.total_chili = harvest_count
			if plant.name == "Eggplant":
				globals.total_eggplant = harvest_count
				
			plant.get_node("Sprite/Count").text = str(harvest_count)

func _on_MonsterDead():
	# once the monster is dead, new boss will show until the time ends
	monster_respawn_timer.start()
	pass

func create_new_monster(stage):
	var monster = null
	if stage == 1:
		monster = load("res://scenes/monsters/bat/Bat.tscn").instance()
	elif stage == 2:
		monster = load("res://scenes/monsters/giganoodle/Giganoodle.tscn").instance()
	elif stage == 3:
		monster = load("res://scenes/monsters/eyeball/Eyeball.tscn").instance()
	elif stage == 4:
		monster = load("res://scenes/monsters/bee/Bee.tscn").instance()
	elif stage == 5:
		monster = load("res://scenes/monsters/maneater/ManEater.tscn").instance()
		
	monster.position = Vector2(365, -95)
	monster.playing = false
	monster.connect("attack_crop", self, "_on_AttackCrop")
	monster.connect("monster_dead", self, "_on_MonsterDead")
	
	monsters.add_child(monster)
	monster.get_node("Anim").play("approach")

func remove_monster_in_screen():
	for monster in monsters.get_children():
		monster.queue_free()

func _on_MonsterRespawnTimer_timeout():
	create_new_monster(globals.current_stage)
	pass # Replace with function body.

func _on_DamageMonster(damage):
	if monsters.get_child_count() != 0:
		var monster = monsters.get_children()[0]
		monster.received_attack(damage)
	pass

func _on_Update_PlantHarvest(plant_name):
	var updated_count = 0
	if plant_name == "Tomato":
		globals.total_tomato += 1
		updated_count = globals.total_tomato
	elif plant_name == "Cabbage":
		globals.total_cabbage += 1
		updated_count = globals.total_cabbage
	elif plant_name == "Chili":
		globals.total_chili += 1
		updated_count = globals.total_chili
	elif plant_name == "Eggplant":
		globals.total_eggplant += 1
		updated_count = globals.total_eggplant
		
	harvests.get_node(plant_name + "/Sprite/Count").text = str(updated_count)

func _on_CloudTransition_Played():
	time_transition.play_time_transition(current_time_scene)
	cloud_transition.is_input_disable = true

func _on_Continue_pressed():
	stage_time_pause_now = OS.get_ticks_msec()
	pause_time_value += stage_time_pause_now - stage_time_pause_start
	get_tree().paused = false
	pause_container.visible = false
	pass # Replace with function body.

func _on_GamePaused():
	stage_time_pause_start = OS.get_ticks_msec()
	pause_container.visible = true
	get_tree().paused = true
