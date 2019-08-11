extends Node2D

const BACKSPACE_CODE = 16777220
const SHIFT_CODE = 16777237
const ENTER_CODE = 16777221
const SPACE_CODE = 32
const A_CODE = 65
const Z_CODE = 90
const ZERO_CODE = 48
const NINE_CODE = 57

var is_shift_on = false
var typed = ""

var text_count = 5
var initial_location = Vector2(30, 30)

var text_scn = load("res://base/Text/Text.tscn")
const TextPool = preload("res://scripts/Text_Pool.gd")
onready var text_pool = TextPool.new() 

signal water_plants

func _ready():
	var text_count = 5
	for i in range(text_count):
		var text = text_scn.instance()
		text.initialize_text(Vector2(30,30) * (i + 1), text_pool.stage.pool[randi() % text_pool.stage.pool.size()])
#		var text = $TextsContainer/Text.duplicate(8)
#		text.position = Vector2(30,30) * (i + 1)
#		text.get_node("Label").text = "Random word here " + str(i)
#		text.get_node("LabelBold").text = text.get_node("Label").text
#		text.get_node("LabelBold").bbcode_text = "[color=red]" + text.get_node("Label").text + "[/color]"
#		text.get_node("LabelBold").visible_characters = 0
		$TextsContainer.add_child(text)
	pass # Replace with function body.

func _process(delta):
	var text_nodes = $TextsContainer.get_children()
	for nodes in text_nodes:
		nodes.position.y += 0.2
	pass

func _input(event):
	if event is InputEventKey:
#		print(event.scancode)
		if event.scancode == SHIFT_CODE:
			is_shift_on = event.pressed
			print("SHIFT " + ("ON" if is_shift_on else "OFF" ))
		elif event.scancode == ENTER_CODE and event.pressed:
			check_input_from_text_list(typed)
			typed = ""
			print("ENTER")
		elif event.pressed:
			var code = event.scancode
			print(code)
			if code >= A_CODE and code <= Z_CODE:
				if !is_shift_on:
					code += 32
				typed += OS.get_scancode_string(code)
			elif code == SPACE_CODE:
				typed += " "
			elif code >= ZERO_CODE and code <= NINE_CODE:
				typed += OS.get_scancode_string(code)
			elif code == BACKSPACE_CODE:
				typed.erase(typed.length()-1, 1)
			highlight_texts_from_input(typed)
		
		print(typed)
		$Input.text = typed

func highlight_texts_from_input(input):
	var text_nodes = $TextsContainer.get_children()
	for node in text_nodes:
		var label_bold = node.get_node("LabelBold") 
		if label_bold.text.find(typed, 0) == 0:
			label_bold.visible_characters = typed.length()
		else:
			label_bold.visible_characters = 0
			pass

func check_input_from_text_list(input):
	var text_nodes = $TextsContainer.get_children()
	for node in text_nodes:
		var label_bold = node.get_node("LabelBold")
		if label_bold.text == input:
			node.queue_free()
			# Trigger signal here passing collected points
			emit_signal("water_plants", node.position)
			print("MATCHED")
		else:
			label_bold.visible_characters = 0
	pass