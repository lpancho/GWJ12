extends Node2D

var harvest_time_color = Color("#1900f832")
var defend_time_color = Color("#19f83400")
var other_time_color = Color("#190084f8")
onready var label = $Label
onready var anim = $Anim
enum time_scene {MORNING, EVENING, CLEANING}
var current_time_scene
var transition_end = false
signal start_stage

func play_time_transition(_current_time_scene):
	current_time_scene = _current_time_scene
	var rect_color
	if current_time_scene == time_scene.MORNING:
		label.text = "HARVEST TIME!!!"
		rect_color = harvest_time_color
	elif current_time_scene == time_scene.EVENING:
		label.text = "DEFEND TIME!!!"
		rect_color = defend_time_color
	elif current_time_scene == time_scene.CLEANING:
		label.text = "CLEANING TIME!!!"
		rect_color = other_time_color
		
	for child in get_children():
		if child is ColorRect:
			child.color = rect_color
	
	anim.play("time_transition_start")

func _on_Anim_animation_finished(anim_name):
	if anim_name == "time_transition_start":
		anim.play("time_transition_end")
	if anim_name == "time_transition_end":
		emit_signal("start_stage", current_time_scene)
	pass # Replace with function body.
