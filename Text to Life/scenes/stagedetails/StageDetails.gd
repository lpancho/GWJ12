extends Node2D

const SPACE_CODE = 32

onready var stage_anim = $Anim
onready var skip = $details/Skip
onready var skip_anim = $details/Skip/Anim
onready var message = $details/Message
onready var message_anim = $details/Anim

var message_index = 0
const MAX_MESSAGE_INDEX = 1
var messages = [
	"Hey! So you are the hero? The farm-type hero! And you are here to help me! Right?\n\nDon't worry I will not tell you a story!  It is just here to practice my godotanimation! Nevermind!",
	"So... This is a challenge to you! You'll help me to harvest crops in the morning and fight monster at night!\n\nSounds exciting?! Not to me!"
]

# Called when the node enters the scene tree for the first time.
func _ready():
	message.text = messages[message_index]
	message.visible_characters = 0
	message_anim.play("show_characters")
	
	skip.text = "Press [SPACE] to skip this nonsense..."
	skip_anim.play("blink")
	pass # Replace with function body.

func _input(event):
	if event is InputEventKey:
		if event.scancode == SPACE_CODE and event.pressed:
			if message_index != MAX_MESSAGE_INDEX:
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