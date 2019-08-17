extends Node2D

func initialize_text(pos, text):
	position = pos
	get_node("Label").text = text
	get_node("LabelBold").text = get_node("Label").text
	get_node("LabelBold").bbcode_text = "[color=red]" + get_node("Label").text + "[/color]"
	get_node("LabelBold").visible_characters = 0

func remove_text():
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(
		self,
		"scale", self.scale, Vector2(0.1, 0.1),
		0.2, Tween.TRANS_ELASTIC, Tween.EASE_IN_OUT)
	tween.connect("tween_all_completed", self, "_on_Tween_all_completed")
	tween.start()

func _on_Tween_all_completed():
	queue_free()
