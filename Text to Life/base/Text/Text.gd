extends Node2D

func initialize_text(pos, text):
	position = pos
	get_node("Label").text = text
	get_node("LabelBold").text = get_node("Label").text
	get_node("LabelBold").bbcode_text = "[color=red]" + get_node("Label").text + "[/color]"
	get_node("LabelBold").visible_characters = 0
