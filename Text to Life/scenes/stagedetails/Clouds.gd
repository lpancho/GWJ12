extends Node2D

onready var c1 = $cloud1
onready var c2 = $cloud2
onready var c3 = $cloud3

const MAX_TIME_TO_MOVE = 80
var current_time = 0

func _process(delta):
	if current_time != MAX_TIME_TO_MOVE:
		current_time += 1
	else:
		current_time = 0
		animate_clouds()

func animate_clouds():
	var tween = Tween.new()
	tween.name = "TweenClouds"
	add_child(tween)
	
	tween.interpolate_property(
		c1,
		"position", c1.position, random_movement(c1.position),
		1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	tween.interpolate_property(
		c2,
		"position", c2.position, random_movement(c2.position),
		1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	tween.interpolate_property(
		c3,
		"position", c3.position, random_movement(c3.position),
		1, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func random_movement(pos):
	randomize()
	var is_positive = false
	if randi() % 10 < 5:
		is_positive = true
	
	var vectors = [Vector2(10, 0), Vector2(15, 0), Vector2(20, 0)]
	if self.name == "lower":
		vectors = [Vector2(3, 0), Vector2(5, 0), Vector2(8, 0)]
		
	if is_positive:
		pos = pos + (vectors[randi() % vectors.size()])
	else:
		pos = pos - (vectors[randi() % vectors.size()])
	return pos