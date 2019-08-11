extends Sprite

onready var tween = $Tween

func animate(start_pos, end_pos, start_rot, end_rot):
	tween.interpolate_property(
		self,
		"position", start_pos, end_pos,
		1, Tween.TRANS_ELASTIC, Tween.EASE_OUT); 
	tween.interpolate_property(
		self,
		"rotation", start_rot, end_rot,
		1, Tween.TRANS_ELASTIC, Tween.EASE_OUT); 
	tween.start()

func _on_Tween_tween_completed(object, key):
	object.visible = false
	
	pass # Replace with function body.
