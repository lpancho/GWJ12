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

var text_scn = load("res://base/Text/Text.tscn")
var TextPool = load("res://scripts/Text_Pool.gd")
onready var text_pool = TextPool.new() 
onready var timer_create_text = $TimerCreateText
onready var texts_container = get_node("TextsContainer")
onready var label_combo = $Labels/Combo
onready var label_input = $Labels/Input
onready var label_comboresettime = $Labels/ComboResetTime
onready var clouds = $Clouds
var created_texts = []
var chain_count = 0
var max_chain_count = 15
var chain_time_start = 0
var chain_time_now = 0
var enable_input = false
var current_weapon
var current_weapon_combo = 0
const CHAIN_TIMER = 5000

enum time_scene {MORNING, EVENING, CLEANING}
var current_time_scene = time_scene.MORNING

enum char_modulation {LOWER_CASE, UPPER_CASE, FIRST_LETTER_UPPER_CASE, INDEFINITE_UPPERCASE, LOWER_CASE_JUMBLED_LETTERS}
var current_char_modulation

signal water_plants
signal attack_enemies

func _ready():
	clouds.set_process(false)

func _process(delta):
	var text_nodes = texts_container.get_children()
	for node in text_nodes:
		node.position.y += 0.1
		if node.position.y > 300:
			node.queue_free()
	if chain_count > 0:
		display_chain_time()
	pass

func display_chain_time():
	chain_time_now = OS.get_ticks_msec()
	
	var elapsed = CHAIN_TIMER - (chain_time_now - chain_time_start)
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	var seconds = clamp(elapsed / 1000, 0, 5)
#	prints(elapsed, seconds, milliseconds)
	var str_elapsed = "%01d : %03d" % [seconds, milliseconds]
	if milliseconds == 0 and seconds == 0:
		chain_count = 0
		label_combo.text = "Combo: " + str(chain_count)
		label_comboresettime.text = "Combo Reset Time: 5.000"
	else:
		label_comboresettime.text = "Combo Reset Time: " + str_elapsed

func _input(event):
	if event is InputEventKey and enable_input:
		if event.scancode == SHIFT_CODE:
			is_shift_on = event.pressed
			print("SHIFT " + ("ON" if is_shift_on else "OFF" ))
		elif event.scancode == ENTER_CODE and event.pressed:
			check_input_from_text_list(typed)
			typed = ""
			highlight_texts_from_input(typed)
			print("ENTER")
		elif event.pressed:
			var code = event.scancode
			if code >= A_CODE and code <= Z_CODE and typed.length() < 16:
				if !is_shift_on:
					code += 32
				typed += OS.get_scancode_string(code)
			elif code == SPACE_CODE and typed.length() < 16:
				typed += " "
			elif code >= ZERO_CODE and code <= NINE_CODE and typed.length() < 16:
				typed += OS.get_scancode_string(code)
			elif code == BACKSPACE_CODE:
				typed.erase(typed.length()-1, 1)
			highlight_texts_from_input(typed)
			
		label_input.text = typed

func highlight_texts_from_input(input):
	var text_nodes = texts_container.get_children()
	for node in text_nodes:
		var label_bold = node.get_node("LabelBold")
		# we can have a condition here for the conditions of different difficulty 
		# we need also to add this to the check_input_from_text_list method
		# for now we will just use lower case
		var label_text = node.get_node("Label").text.to_lower()
		if label_text.find(typed, 0) == 0:
			label_bold.visible_characters = typed.length()
		else:
			label_bold.visible_characters = 0
			pass

func check_input_from_text_list(input):
	var text_nodes = texts_container.get_children()
	for node in text_nodes:
		var label_bold = node.get_node("LabelBold")
		var label_text = node.get_node("Label").text.to_lower()
		if label_text == input:
			node.queue_free()
			# Trigger signal here passing collected points
			
			
			if current_time_scene == time_scene.MORNING:
				chain_count += 1
				chain_count = clamp(chain_count, 0, max_chain_count)
				emit_signal("water_plants", node.position, chain_count)
			else:
				if current_weapon == "" or current_weapon != input:
					current_weapon = input
					chain_count = 1
				elif current_weapon == input:
					chain_count += 1
					chain_count = clamp(chain_count, 0, max_chain_count)
				
				var weapon_object = get_weapon_object_from_pool(current_weapon)
				emit_signal("attack_enemies", node.position, chain_count, weapon_object)
			label_combo.text = "Combo: " + str(chain_count)
			if chain_count > 0:
				chain_time_start = OS.get_ticks_msec()
			print("MATCHED")
			break
		else:
			label_bold.visible_characters = 0
	pass

func create_new_text():
	var text = text_scn.instance()
	var found = false
	var counter_find = 0
	
	var stage_num = 1
	if stage_num == 1:
		current_char_modulation = char_modulation.LOWER_CASE
	
##	disregard the distinct word to show
	if current_time_scene == time_scene.MORNING:
		var pool_length = text_pool.pool_harvest.size()
		while !found:
			randomize()
			var found_text = remodulate_text(text_pool.pool_harvest[randi() % pool_length])
			if !is_in_created_texts(found_text):
				found = true
				text.initialize_text(Vector2(rand_range(1, 200), 60), found_text)
				created_texts.append(found_text)
				texts_container.add_child(text)
				timer_create_text.start()
				
			counter_find += 1
			if counter_find == pool_length:
				break
				
##	create text even it is duplicate
	elif current_time_scene == time_scene.EVENING:
		var pool_length = text_pool.pool_weapons.size()
		var text_weapon = text_pool.pool_weapons[randi() % pool_length]
		var text_weapon_name = remodulate_text(text_weapon.name)
		text.initialize_text(Vector2(rand_range(1, 200), 60), text_weapon_name)
		texts_container.add_child(text)
		timer_create_text.start()

func is_in_created_texts(found_text):
	for text in created_texts:
		if text == found_text:
			return true
	return false

func _on_TimerCreateText_timeout():
	create_new_text()
	pass # Replace with function body.

func clean():
	is_shift_on = false
	typed = ""
	created_texts = []
	chain_count = 0
	chain_time_start = 0
	chain_time_now = 0
	label_input.text = typed
	label_comboresettime.text = "Combo Reset Time: 5.000"
	label_combo.text = "Combo: 0"

func get_weapon_object_from_pool(weapon_name):
	for weapon in text_pool.pool_weapons:
		if weapon.name.to_lower() == weapon_name.to_lower():
			return weapon.object

func remodulate_text(text):
	if current_char_modulation == char_modulation.LOWER_CASE:
		return text.to_lower()
	elif current_char_modulation == char_modulation.UPPER_CASE:
		return text.to_upper()
	elif current_char_modulation == char_modulation.FIRST_LETTER_UPPER_CASE:
		# this is the default text in the text pool
		pass
	elif current_char_modulation == char_modulation.INDEFINITE_UPPERCASE:
		randomize()
		# set the first letter fot the text to lower
		# default is upper case
		text[0] = text[0].to_lower()
		for i in text.length():
			if randi() % 10 < 5:
				text[i] = text[i].to_upper()
		pass
	elif current_char_modulation == char_modulation.LOWER_CASE_JUMBLED_LETTERS:
		text[0] = text[0].to_lower()
		text = text.shuffle()
		pass
	return text
	pass

func enable_process(value):
	set_process(value)
	clouds.set_process(value)
	enable_input = value
	if value:
		timer_create_text.start()
	else:
		timer_create_text.stop()