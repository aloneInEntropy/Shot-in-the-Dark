extends KinematicBody2D

signal no_health

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var coll = $CollisionShape2D
onready var intbox = $InteractBox
onready var powerup_timer := $PowerupTimer
onready var world = get_tree().get_root().get_node_or_null("World")

var pattern := PoolVector2Array() # light bullet pattern
var health_loss_rate = 120 # frames to pass before losing 1 health
var health_loss_frame = health_loss_rate
var max_health : float
var health := max_health
var max_hunger : float
var hunger := max_hunger
var power_up : String
var powered_up : bool
var items = ["Bread", "Cupcake", "Sweet", "WaterBottle", "Chicken", "Cloth", "Dumbbell"] # all items
var accepted_foods = [] # items the npc can eat for a health bonus
var rejected_foods = [] # foods that will hurt the npc (physically, emotionally, etc.) when eaten
var powerup_foods = {} # items that will empower the npc when eaten
# var powerup_times = [] # powerup times for each powerup

func updateHealth(amount: float):
	if health_loss_frame <= 0:
		health += amount
		health_loss_frame = health_loss_rate
		if (health <= 0):
			emit_signal("no_health")
	
	health_loss_frame -= 1
	

func play_anim(name: String):
	anim.play(name)
	coll.disabled = true
	
func stop_anim():
	anim.stop()
	coll.disabled = false

func receive_item(item):
	var item_name = item.name
	if item_name in accepted_foods:
		if !(item_name in ["Cloth", "Dumbbell"]):
			health += 15
			print("%s got some food (%s)" % [name, item_name])
	elif item_name in rejected_foods:
		if !(item_name in ["Cloth", "Dumbbell"]):
			health -= 15
			print(name + " can't eat this! it's bad for them :( (" + item_name + ")")
	elif item_name in powerup_foods:
		start_powerup(item_name, powerup_foods[item_name])
		if !(item_name in ["Cloth", "Dumbbell"]):
			health += 30
			print("%s got a super power! (%s)" % [name, item_name])
			# print(name + " got a super power! (" + item_name + ")")
	else: 
		print(name + " got something they don't understand (" + item_name + ")")
			
func start_powerup(item: String, t: float):
	powered_up = true
	power_up = item
	powerup_timer.start(t)
	
func end_powerup():
	powered_up = false
	power_up = ""


func _on_PowerupTimer_timeout():
	end_powerup()


func _on_NPC_no_health():
	print("%s died!" % name)
	queue_free()
