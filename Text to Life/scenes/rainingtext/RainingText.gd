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
const TextPool = preload("res://scripts/Text_Pool.gd")
onready var text_pool = TextPool.new() 
onready var timer_create_text = $TimerCreateText

signal water_plants
var created_texts = []
var chain_count = 0
var chain_time_start = 0
var chain_time_now = 0
const CHAIN_TIMER = 5000

func _ready():
	timer_create_text.start()
	pass # Replace with function body.

func _process(delta):
	var text_nodes = $TextsContainer.get_children()
	for nodes in text_nodes:
		nodes.position.y += 0.1
	if chain_count > 0:
		display_chain_time()
	pass

func display_chain_time():
	chain_time_now = OS.get_ticks_msec()
	
	var elapsed = CHAIN_TIMER - (chain_time_now - chain_time_start)
	var milliseconds = clamp(elapsed % 1000, 0, 999)
	var seconds = clamp(elapsed / 1000, 0, 5)
	prints(elapsed, seconds, milliseconds)
	var str_elapsed = "%01d : %03d" % [seconds, milliseconds]
	if milliseconds == 0 and seconds == 0:
		chain_count = 0
		$Chain.text = "Chain: " + str(chain_count)
		$ChainResetTime.text = "Chain Reset Time: 5.000"
	else:
		$ChainResetTime.text = "Chain Reset Time: " + str_elapsed

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
			emit_signal("water_plants", node.position, chain_count)
			chain_count += 1
			chain_count = clamp(chain_count, 0, 4)
			$Chain.text = "Chain: " + str(chain_count)
			if chain_count > 0:
				chain_time_start = OS.get_ticks_msec()
			print("MATCHED")
		else:
			label_bold.visible_characters = 0
	pass

func create_new_text():
	var text = text_scn.instance()
	var found = false
	var pool_length = text_pool.pool.size()
	var counter_find = 0
	print(pool_length)
	
##	create text even it is duplicate
#	var found_text = text_pool.stage.pool[randi() % text_pool.stage.pool.size()]
#	text.initialize_text(Vector2(rand_range(1, 200), 0), found_text)
#	$TextsContainer.add_child(text)
#	timer_create_text.start()
	
##	disregard the distinct word to show
	while !found:
		randomize()
		var found_text = text_pool.pool[randi() % text_pool.pool.size()]
		if !is_in_created_texts(found_text):
			found = true
			text.initialize_text(Vector2(rand_range(1, 200), 0), found_text)
			created_texts.append(found_text)
			$TextsContainer.add_child(text)
			timer_create_text.start()

		counter_find += 1
		if counter_find == pool_length:
			break

func is_in_created_texts(found_text):
	for text in created_texts:
		if text == found_text:
			return true
	return false

func _on_TimerCreateText_timeout():
	create_new_text()
	pass # Replace with function body.
