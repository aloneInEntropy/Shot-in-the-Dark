extends KinematicBody2D

signal no_health

onready var anim = $AnimationPlayer
onready var sprite = $Sprite
onready var coll = $CollisionShape2D
onready var intbox = $InteractBox
onready var world = get_tree().get_root().get_node_or_null("World")

var pattern := PoolVector2Array() # light bullet pattern
var health_loss_rate = 120 # frames to pass before losing 1 health
var health_loss_frame = health_loss_rate
export var max_health = 100
onready var health = max_health

func _ready():
	# print(global_position)
	if name == "Orion":
		sprite.texture = load("res://Assets/Spritesheets/orion.png")
		pattern.append(Vector2(0, 0))
		pattern.append(Vector2(world.gap, 0))
		pattern.append(Vector2(-world.gap, 0))
		pattern.append(Vector2(0, world.gap))
	elif name == "Petra":
		sprite.texture = load("res://Assets/Spritesheets/petra.png")
	elif name == "Oasis":
		sprite.texture = load("res://Assets/Spritesheets/oasis.png")
	elif name == "Aurora":
		sprite.texture = load("res://Assets/Spritesheets/aurora.png")
	elif name == "Borealis":
		sprite.texture = load("res://Assets/Spritesheets/borealis.png")
	elif name == "Mark":
		sprite.texture = load("res://Assets/Spritesheets/mark.png")

	anim.play("walk_r")
	intbox.name = name

func _physics_process(_delta):
	if health_loss_frame <= 0:
		health -= 1
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
	if item_name == "Bread" or item_name == "Water":
		health += 15
	elif item_name in ["Sweet", "Cupcake"] and name == "Orion":
		health -= 15
	elif item_name == "Chicken" and name == "Aurora":
		health -= 15
	elif item_name == "Cupcake" and name == "Borealis":
		health -= 15
	else:
		print(name + " got something they don't understand (" + item_name + ")")
	pass
