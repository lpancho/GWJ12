extends Node

# Stage
var current_stage = 1
const MAX_STAGE = 5

# Scores
var total_tomato = 0
var total_cabbage = 0
var total_chili = 0
var total_eggplant = 0

func update_current_stage():
	current_stage += 1
	current_stage = clamp(current_stage, 1, MAX_STAGE)

func get_boss_name(stage_num):
	if stage_num == 1:
		return "GIANT FRUIT BAT"
	elif stage_num == 2:
		return "GIGANOODLE"
	elif stage_num == 3:
		return "AY AY BALL"
	elif stage_num == 4:
		return "QUEEN BEE"
	elif stage_num == 5:
		return "MAN EATAH"

func get_max_combo(stage_num):
	if stage_num == 1:
		return 5
	elif stage_num == 2:
		return 10
	elif stage_num == 3:
		return 12
	elif stage_num == 4:
		return 14
	elif stage_num == 5:
		return 16

func get_stage_requirements(stage_num):
	var requirements = []
	if stage_num == 1:
		requirements.append({"fruit_name": "Tomato", "count": 250})
	elif stage_num == 2:
		requirements.append({"fruit_name": "Tomato", "count": 250})
		requirements.append({"fruit_name": "Cabbage", "count": 150})
	elif stage_num == 3:
		requirements.append({"fruit_name": "Tomato", "count": 250})
		requirements.append({"fruit_name": "Cabbage", "count": 150})
		requirements.append({"fruit_name": "Chili", "count": 25})
	elif stage_num == 4:
		requirements.append({"fruit_name": "Tomato", "count": 250})
		requirements.append({"fruit_name": "Cabbage", "count": 150})
		requirements.append({"fruit_name": "Chili", "count": 25})
		requirements.append({"fruit_name": "Eggplant", "count": 5})
	elif stage_num == 5:
		requirements.append({"fruit_name": "Tomato", "count": 450})
		requirements.append({"fruit_name": "Cabbage", "count": 250})
		requirements.append({"fruit_name": "Chili", "count": 45})
		requirements.append({"fruit_name": "Eggplant", "count": 25})
	
	return requirements

func check_if_requirements_met():
	var reqs = get_stage_requirements(current_stage)
	for item in reqs:
		prints(item, total_tomato)
		if item.fruit_name == "Tomato" and total_tomato <= int(item.count):
			return false
		elif item.fruit_name == "Cabbage" and total_cabbage <= int(item.count):
			return false
		elif item.fruit_name == "Chili" and total_chili <= int(item.count):
			return false
		elif item.fruit_name == "Eggplant" and total_eggplant <= int(item.count):
			return false
	return true