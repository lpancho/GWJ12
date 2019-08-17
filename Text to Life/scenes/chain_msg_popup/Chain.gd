extends CanvasLayer

onready var combo = $Combo
onready var count = $Combo/Count
onready var tween = $Tween
var label_offset = Vector2(0, 5)

func initialize(_position, chain_num):
	count.text = str(chain_num)
	combo.rect_position = _position
	animate()

func animate():
	tween.interpolate_property(
		combo,
		"rect_position", combo.rect_position, combo.rect_position + label_offset,
		1, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween.start()
	pass

func _on_Tween_tween_all_completed():
	queue_free()
	pass # Replace with function body.
