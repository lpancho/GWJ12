extends Node2D

onready var anim = $Anim as AnimationPlayer
onready var tween = $Tween as Tween

var damage = 1
var offset = Vector2(0, 30)
signal damage_monster

func move(start_pos, monster_position):
	tween.interpolate_property(
		self,
		"position", start_pos, monster_position + offset,
		0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	tween.start()

func _on_Tween_tween_all_completed():
	anim.play("attack")
	pass # Replace with function body.

func _on_Anim_animation_finished(anim_name):
	if anim_name == "attack":
		emit_signal("damage_monster", damage)
		queue_free()
	pass # Replace with function body.


