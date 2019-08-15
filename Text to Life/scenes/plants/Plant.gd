extends Node2D

const MAX_SPRITE = 6
const MIN_SPRITE = 1
var current_sprite = MIN_SPRITE
var health 

var plant_name
var produced_plant = false

var plant_movement = Vector2(0, -35)
onready var tween = $Tween
onready var plant_sprite = $Sprite6

const TIME_TO_PRODUCE = 120
var current_time = 0

signal update_plant_harvest

func _ready():
	tween.connect("tween_completed", self, "_on_Tween_tween_completed")

func _process(delta):
	if produced_plant:
#		print(current_sprite)
		current_time += 1
		if current_time == int(TIME_TO_PRODUCE / 3) || current_time == int(TIME_TO_PRODUCE / 2):
			show_next_sprite()
		elif current_time == TIME_TO_PRODUCE:
			current_time = 0
			show_next_sprite()
			show_produced_fruit()

func update_plant():
	if current_sprite < MAX_SPRITE:
		show_next_sprite()
		if current_sprite == MAX_SPRITE - 1:
			show_produced_fruit()

func show_next_sprite():
	if current_sprite != 5:
		get_node("Sprite" + str(current_sprite)).visible = false
	current_sprite += 1
	current_sprite = clamp(current_sprite, 0, MAX_SPRITE)
	get_node("Sprite" + str(current_sprite)).visible = true

func show_produced_fruit():
	plant_sprite.visible = true
	tween.interpolate_property(
		plant_sprite,
		"position", plant_sprite.position, plant_sprite.position + plant_movement,
		1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_completed(object, key):
	object.visible = false
	object.position -= plant_movement
	current_sprite = 2
	emit_signal("update_plant_harvest", plant_name)
	
	if !produced_plant:
		produced_plant = true
	pass # Replace with function body.

func enable_process(value):
	set_process(value)
	if produced_plant:
		get_node("Sprite" + str(current_sprite)).visible = false
		get_node("Sprite4").visible = true

func monster_get_plant(monster):
	var plant = plant_sprite.duplicate(8)
	plant.visible = true
	var plant_tween = Tween.new()
	plant_tween.interpolate_property(
		plant,
		"position", plant.position, monster.position,
		1, Tween.TRANS_CIRC, Tween.EASE_IN)
	plant_tween.connect("tween_all_completed", self, "_on_PlantTween_tween_completed")
	get_parent().add_child(plant)
	get_parent().add_child(plant_tween)
	plant_tween.start()

func _on_PlantTween_tween_completed():
	print("askdhalksdhlaksd HEHHHEHER")