extends AnimatedSprite

var damage = 1
var MAX_HEALTH = 1
var health = 1
var harvest_steal = 0

onready var attack_timer_node = $AttackTimer as Timer
onready var anim = $Anim as AnimationPlayer
onready var hitandblood = $HitAndBlood as AnimatedSprite
onready var healthbar = $HealthBar as ProgressBar
onready var harveststealbar = $HarvestStealBar as ProgressBar
signal attack_crop
signal monster_dead

func send_attack():
	emit_signal("attack_crop", damage)

func received_attack(damage):
	health -= damage
	health = clamp(health, 0, MAX_HEALTH)
	healthbar.value = health
	hitandblood.visible = true
	hitandblood.play("hit")
	
	if health == 0:
		healthbar.visible = false
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

func stop_attack():
	attack_timer_node.stop()