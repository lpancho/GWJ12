extends Node2D

const Z_CODE = 90
const A_CODE = 65
const SPACE_CODE = 32
const ENTER_CODE = 16777221
const BACKSPACE_CODE = 16777220

onready var anim = $Anim
onready var requirement_container = $Container/Requirements
onready var boss_goal = $Container/BossGoal
onready var combo_details = $Container/ComboDetails
onready var input = $Container/RequirementDidNotMet/Input
onready var ending_input = $Container/Ending/Input
const boss_goal_format = "DEFEAT THE [color=red]{0}[/color]!!!"
const combo_details_format = "MAXIMUM COMBO [color=blue]x{0}[/color]!!!"
var is_played_backwards = false
var is_input_disable = false
var did_not_met = false
var ending = false
var typed = ""

signal cloud_transition_played

func _ready():
	for requirement_node in requirement_container.get_children():
		requirement_node.visible = false
	setup_requirements(1)
	pass

func show_did_not_met():
	did_not_met = true
	anim.play("didnotmet")

func show_ending():
	ending = true
	anim.play("ending")

func setup_requirements(stage_num):
	is_played_backwards = false
	boss_goal.bbcode_text = boss_goal_format.replace("{0}", globals.get_boss_name(stage_num))
	combo_details.bbcode_text = combo_details_format.replace("{0}", globals.get_max_combo(stage_num))
	
	var requirements = globals.get_stage_requirements(stage_num)
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
	if !is_input_disable and event is InputEventKey  and event.pressed:
		if !did_not_met and !ending and event.scancode == SPACE_CODE:
			is_played_backwards = true
			play_animation(true)
		elif did_not_met:
			var code = event.scancode
			if code >= A_CODE and code <= Z_CODE and typed.length() < 7:
				typed += OS.get_scancode_string(code)
				input.text = typed + "..."
			elif code == BACKSPACE_CODE:
				typed.erase(typed.length()-1, 1)
				input.text = typed + "..."
			elif code == ENTER_CODE:
				if typed == "RETRY":
					get_tree().reload_current_scene()
				elif typed == "MENU":
					get_tree().change_scene("res://scenes/mainmenu/MainMenu.tscn")
		elif ending:
			var code = event.scancode
			if code >= A_CODE and code <= Z_CODE and typed.length() < 7:
				typed += OS.get_scancode_string(code)
				ending_input.text = typed + "..."
			elif code == BACKSPACE_CODE:
				typed.erase(typed.length()-1, 1)
				ending_input.text = typed + "..."
			elif code == ENTER_CODE:
				if typed == "MENU":
					get_tree().change_scene("res://scenes/mainmenu/MainMenu.tscn")

func _on_Anim_animation_finished(anim_name):
	if anim_name == "enter" and is_played_backwards:
		print("emit")
		emit_signal("cloud_transition_played")
	pass # Replace with function body.
