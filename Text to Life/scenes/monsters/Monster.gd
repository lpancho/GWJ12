extends AnimatedSprite

var damage = 1
var health = 1

var is_alive = true

onready var attack_timer_node = $AttackTimer as Timer
onready var anim = $Anim as AnimationPlayer
onready var hitandblood = $HitAndBlood as AnimatedSprite
signal attack_crop
signal monster_dead

func send_attack():
	emit_signal("attack_crop", damage)

func received_attack(damage):
	health -= damage
	hitandblood.visible = true
	hitandblood.play("hit")
	
	if health == 0:
		attack_timer_node.stop()
		anim.play("dead")
		pass

func attack():
	anim.play("attack")
	pass

func _on_AttackTimer_timeout():
	attack()
	attack_timer_node.start()
	pass # Replace with function body.

func _on_HitAndBlood_animation_finished():
	hitandblood.visible = false
	hitandblood.stop()
	hitandblood.frame = 0
	pass # Replace with function body.

func _on_Anim_animation_finished(anim_name):
	if anim_name == "dead":
		emit_signal("monster_dead")
		queue_free()
	elif anim_name == "approach":
		playing = true
	pass # Replace with function body.