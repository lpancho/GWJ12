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


func _ready():
	title.get_node("LabelBold").visible_characters = 0
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey and event.scancode == ENTER_CODE and event.pressed:
		check_input_from_text_list(typed)
		typed = ""
		print("ENTER")
	elif event is InputEventKey and event.pressed:
		var code = event.scancode
		print(code)
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
	var label_bold = title.get_node("LabelBold") 
	if label_bold.text.find(typed, 0) == 10:
		label_bold.visible_characters = 10 + typed.length()
	else:
		label_bold.visible_characters = 0
		pass

func check_input_from_text_list(input):
	var label_bold = title.get_node("LabelBold")
	if input == "HERO":
		get_tree().change_scene("res://scenes/Tutorial.tscn")
		print("MATCHED")
	else:
		label_bold.visible_characters = 0