extends "res://Scripts/NPC.gd"


func _ready():
	sprite.texture = load("res://Assets/Spritesheets/orion.png")
	accepted_foods = ["WaterBottle", "Bread", "Chicken", "Cloth", "Dumbbell"] # accept all foods
	rejected_foods = ["Sweet", "Cupcake"]
	powerup_foods = {}

	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	pattern.append(Vector2(-world.gap, 0))
	pattern.append(Vector2(0, world.gap))
	pattern.append(Vector2(0, -world.gap))
	pattern.append(Vector2(world.gap, -world.gap))
	pattern.append(Vector2(-world.gap, world.gap))
	pattern.append(Vector2(world.gap, world.gap))
	pattern.append(Vector2(-world.gap, -world.gap))

	intbox.name = name

func _process(_delta):
	updateHealth(-1)