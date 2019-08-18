extends Node2D

const BACKSPACE_CODE = 16777220
const SHIFT_CODE = 16777237
const ENTER_CODE = 16777221
const SPACE_CODE = 32
const A_CODE = 65
const Z_CODE = 90
const ZERO_CODE = 48
const NINE_CODE = 57

var typed = ""
onready var title = $Title
onready var credits = $Credits
onready var quit = $Quit
onready var intro_music = $Intro
var is_in_credits = false

func _ready():
	title.get_node("LabelBold").visible_characters = 0
	credits.get_node("LabelBold").visible_characters = 0
	quit.get_node("LabelBold").visible_characters = 0
	intro_music.play()
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey and event.scancode == ENTER_CODE and event.pressed:
		check_input_from_text_list(typed)
		typed = ""
		print("ENTER")
	elif event is InputEventKey and event.pressed and is_in_credits and event.scancode == BACKSPACE_CODE:
		title.visible = true
		credits.visible = true
		quit.visible = true
		$Subtitle.visible = true
		$CreditDetails.visible = false
		is_in_credits = false
	elif event is InputEventKey and event.pressed:
		var code = event.scancode
		
		if code >= A_CODE and code <= Z_CODE:
			typed += OS.get_scancode_string(code)
		elif code == SPACE_CODE:
			typed += " "
		elif code >= ZERO_CODE and code <= NINE_CODE:
			typed += OS.get_scancode_string(code)
		elif code == BACKSPACE_CODE:
			typed.erase(typed.length()-1, 1)
		highlight_texts_from_input(typed)
		
		print(typed)

func highlight_texts_from_input(input):
	var labels = [
		title.get_node("LabelBold"),
		credits.get_node("LabelBold"),
		quit.get_node("LabelBold")
	]
	
	for label in labels:
		var label_bold = label 
		if label_bold.text.find(input, 0) == 10:
			label_bold.visible_characters = 10 + input.length()
		elif label_bold.text.find(input, 0) == 0:
			label_bold.visible_characters = input.length()
		else:
			label_bold.visible_characters = 0
			pass

func check_input_from_text_list(input):
	var label_bold = title.get_node("LabelBold")
	if input == "HERO":
		get_tree().change_scene("res://scenes/stagedetails/StageDetails.tscn")
		print("MATCHED")
	elif input == "CREDITS":
		title.visible = false
		credits.visible = false
		quit.visible = false
		$Subtitle.visible = false
		$CreditDetails.visible = true
		is_in_credits = true
		pass
	elif input == "QUIT":
		get_tree().quit()
	else:
		label_bold.visible_characters = 0