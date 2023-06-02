extends "res://Scripts/NPC.gd"


func _ready():
	sprite.texture = load("res://Assets/Spritesheets/oasis.png")
	accepted_foods = ["Chicken", "Bread", "Sweet", "Cupcake", "Dumbbell"] # accept all foods
	rejected_foods = []
	powerup_foods = {"WaterBottle":10, "Cloth":10}

	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	pattern.append(Vector2(-world.gap, 0))
	pattern.append(Vector2(0, world.gap))
	pattern.append(Vector2(0, -world.gap))

func _process(_delta):
	updateHealth(-1)