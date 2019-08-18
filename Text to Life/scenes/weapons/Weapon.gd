extends Sprite

onready var anim = $Anim as AnimationPlayer
onready var tween = $Tween as Tween

var level_design = [
	"res://assets/weapons/swords/43.png",
	"res://assets/weapons/swords/44.png",
	"res://assets/weapons/swords/45.png",
	"res://assets/weapons/swords/55.png",
	"res://assets/weapons/swords/56.png",
	"res://assets/weapons/swords/57.png",
	"res://assets/weapons/swords/70.png",
	"res://assets/weapons/swords/71.png",
	"res://assets/weapons/swords/72.png",
	"res://assets/weapons/swords/73.png",
	"res://assets/weapons/swords/74.png",
	"res://assets/weapons/swords/75.png",
	"res://assets/weapons/swords/76.png",
	"res://assets/weapons/swords/77.png",
	"res://assets/weapons/swords/78.png",
	"res://assets/weapons/swords/94.png",
	"res://assets/weapons/swords/95.png",
	"res://assets/weapons/swords/96.png"
]

var damage = 1
var move_offset = Vector2(0, 30)
signal damage_monster

func show_sword_base_on_chain(combo):
	combo = clamp(combo - 1, 0, level_design.size() - 1)
	texture = load(level_design[combo])
	if combo == 0 || combo == 1 || combo == 2:
		flip_h = true
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