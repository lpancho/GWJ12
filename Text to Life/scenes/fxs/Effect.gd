extends Node2D

onready var tween = $Tween
var offset = Vector2(6,24+65)
var selected_plant
func fx_animate(start_pos, end_pos, _selected_plant):
	selected_plant = _selected_plant
	prints("selected_plant", selected_plant.position)
	tween.interpolate_property(
		self,
		"position", start_pos, end_pos + offset,
		1, Tween.TRANS_CIRC, Tween.EASE_OUT)
	tween.start()
	
func _on_Tween_tween_completed(object, key):
	selected_plant.update_plant()
	object.queue_free()
	pass # Replace with function body.
