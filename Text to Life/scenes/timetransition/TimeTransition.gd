extends Node2D

var harvest_time_color = Color("#1900f832")
var defend_time_color = Color("#19f83400")
onready var label = $Label
onready var anim = $Anim
enum time_scene {MORNING, EVENING}

func play_time_transition(current_time_scene):
	var rect_color
	if current_time_scene == time_scene.MORNING:
		rect_color = harvest_time_color
	else:
		rect_color = defend_time_color
		
	for child in get_children():
		if child is ColorRect:
			child.color = rect_color
	
	anim.play("time_transition_start")

func _on_Anim_animation_finished(anim_name):
	if anim_name == "time_transition":
		anim.play("time_transition_end")
	if anim_name == "time_transition_end":
		queue_free()
	pass # Replace with function body.
