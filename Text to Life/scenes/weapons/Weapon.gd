extends Sprite

onready var anim = $Anim as AnimationPlayer
onready var tween = $Tween as Tween

var level_design = [
	"res://assets/weapons/swords/73.png",
	"res://assets/weapons/swords/74.png",
	"res://assets/weapons/swords/75.png"
]

var level = 1
var damage = 1
var move_offset = Vector2(0, 30)
signal damage_monster

func show_sword_base_on_chain(combo):
	combo = clamp(combo-1, 0, level_design.size() - 1)
	texture = load(level_design[combo])
	damage = combo + 1

func move(start_pos, monster_position):
	tween.interpolate_property(
		self,
		"position", start_pos, monster_position + move_offset,
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