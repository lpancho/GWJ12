extends Node2D

const SPACE_CODE = 32

onready var skip = $details/Skip
onready var skip_anim = $details/Skip/Anim
onready var message = $details/Message
onready var message_anim = $details/Anim

var message_index = 0

var messages = [
	"Hey! So you are the hero? The farm-type hero! And you are here to help me! Right? No?\n\nDon't worry I will not tell you a looong story! I'm just practicing my godotanimation! Heh? Nevermind!",
	"So... This is a challenge to you! You'll help me to harvest crops in the morning and also fight monster at night!\n\nSounds exciting?! Not to me!",
	"MORNING:\n\nYou need to type the words present in the left side of screen so that you can water the plants. Obviously, watering the plants makes it grow plus other variables but we will not talk about it right now.",
	"Once the plant grows at its maximum, it will generate a fruit or vegetable depending on its kind.\n\nAfter we filled the whole area, we need a new plant and then cycle until we have the last plant.",
	"EVENING:\n\nMonsters during night time makes us stressed, they are not only attacking our farm but also stealing our morning harvest. When we killed one, they will be respawned again.",
	"CHALLENGE:\n\nIn order for us to know you are the real farm type hero, you'll be challenged for 5 days straight farming and defending with minimum harvest requirement!",
	"Better take note of this, the farm that you harvest from previous days are still counted in the next days.\n\nBetter plan your harvestrategy!",
	"Aaaandd the higher the combo will increase the number of plants you can water AND the damage to monster at night\n\nLet's Go!" 
]
var MAX_MESSAGE_INDEX = messages.size() - 1

# Called when the node enters the scene tree for the first time.
func _ready():
	message.text = messages[message_index]
	message.visible_characters = 0
	message_anim.play("show_characters")
	
	skip.text = "Press [SPACE] to skip..."
	skip_anim.play("blink")
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		if event.scancode == SPACE_CODE and event.pressed:
			if message.visible_characters != messages[message_index].length():
				message.visible_characters = messages[message_index].length()
			elif message_index != MAX_MESSAGE_INDEX:
				message_anim.stop()
				
				message_index += 1
				message_index = clamp(message_index, 0, MAX_MESSAGE_INDEX)
				message.text = messages[message_index]
				message.visible_characters = 0
				
				message_anim.play("show_characters")
				
				if message_index == MAX_MESSAGE_INDEX:
					skip.text = "Press [SPACE] to start farming!"
			else:
				get_tree().change_scene("res://scenes/Tutorial.tscn")

func update_message_visibility():
	var count = message.visible_characters + 1
	count = clamp(count, 0, message.text.length())
	message.visible_characters = count
	
	if count == message.text.length():
		message_anim.stop()
	pass