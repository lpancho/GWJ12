extends Node2D

const SPACE_CODE = 32
onready var anim = $Anim
onready var requirement_container = $Container/Requirements
onready var boss_goal = $Container/BossGoal

const boss_goal_format = "DEFEAT THE [color=red]{0}[/color]!!!"
var is_played_backwards = false

signal cloud_transition_played

func _ready():
	for requirement_node in requirement_container.get_children():
		requirement_node.visible = false
	setup_requirements(1)
	pass

func setup_requirements(stage_num):
	is_played_backwards = false
	var boss_goal_text = boss_goal_format.replace("{0}", get_boss_name(stage_num))
	boss_goal.bbcode_text = boss_goal_text
	
	var requirements = get_stage_requirements(stage_num)
	for requirement in requirements:
		for requirement_node in requirement_container.get_children():
			if requirement_node.name == requirement.fruit_name:
				requirement_node.visible = true
				requirement_node.get_node("Count").text = str(requirement.count)
				break
					
	play_animation(false)

func play_animation(is_backwards):
	if is_backwards:
		anim.play_backwards("enter")
	else:
		anim.play("enter")

func _input(event):
	if event is InputEventKey and event.scancode == SPACE_CODE and event.pressed:
		is_played_backwards = true
		play_animation(true)

func get_boss_name(stage_num):
	if stage_num == 1:
		return "GIANT FRUIT BAT"
	elif stage_num == 2:
		return "GIGANOODLE"

func get_stage_requirements(stage_num):
	var requirements = []
	if stage_num == 1:
		requirements.append({"fruit_name": "Tomato", "count": 250})
	elif stage_num == 2:
		requirements.append({"fruit_name": "Tomato", "count": 250})
		requirements.append({"fruit_name": "Cabbage", "count": 150})
	
	return requirements

func _on_Anim_animation_finished(anim_name):
	if anim_name == "enter" and is_played_backwards:
		print("emit")
		emit_signal("cloud_transition_played")
		
	pass # Replace with function body.
