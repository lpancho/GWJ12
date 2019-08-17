extends AnimatedSprite

onready var tween = $Tween
onready var fruit = $fruit

var health 
var plant_name
var produced_plant = false
var fruit_movement = Vector2(0, -35)
var MAX_ANIM_GROW = 3

signal update_plant_harvest

func _ready():
	self.play("none")
	tween.connect("tween_completed", self, "_on_Tween_tween_completed")

func update_plant():
	if self.animation == "none":
		self.animation = "grow"
		self.stop()
	elif self.animation == "grow" and self.frame != MAX_ANIM_GROW:
		self.frame += 1
	elif self.animation == "grow" and self.frame == MAX_ANIM_GROW:
		self.animation = "reproduce"
		self.stop()
		show_produced_fruit()

func show_produced_fruit():
	fruit.visible = true
	tween.interpolate_property(
		fruit,
		"position", fruit.position, fruit.position + fruit_movement,
		1, Tween.TRANS_ELASTIC, Tween.EASE_OUT)
	tween.start()

func enable_process(value):
	set_process(value)
	self.stop()

func _on_Tween_tween_completed(object, key):
	object.visible = false
	object.position -= fruit_movement
	emit_signal("update_plant_harvest", plant_name)
	
	if !produced_plant:
		produced_plant = true
		self.play()
	pass # Replace with function body.

func _on_Plant_animation_finished():
	if self.animation == "reproduce":
		show_produced_fruit()
	pass # Replace with function body.