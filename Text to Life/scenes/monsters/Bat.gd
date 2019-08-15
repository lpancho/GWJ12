extends "res://scenes/monsters/Monster.gd"

func _ready():
	damage = 3
	health = 20
	
	healthbar.max_value = health
	healthbar.value = health
	
	harvest_steal = 0
	harveststealbar.max_value = 50
	harveststealbar.value = 0
	harveststealbar.percent_visible = false

func send_attack():
	.send_attack()

