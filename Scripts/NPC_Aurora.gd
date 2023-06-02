extends "res://Scripts/NPC.gd"


func _ready():
	sprite.texture = load("res://Assets/Spritesheets/aurora.png")
	accepted_foods = ["Cupcake", "Sweet", "Bread", "WaterBottle", "Cloth", "Dumbbell"] # accept all foods
	rejected_foods = ["Chicken"]
	powerup_foods = {}

	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	pattern.append(Vector2(-world.gap, 0))
	# pattern.append(Vector2(0, world.gap))

func _process(_delta):
	updateHealth(-1)