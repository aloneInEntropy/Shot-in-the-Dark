extends "res://Scripts/NPC.gd"


func _ready():
	sprite.texture = load("res://Assets/Spritesheets/mark.png")
	accepted_foods = items # accept all foods
	rejected_foods = []
	powerup_foods = {"Cloth":10, "Dumbbell":5}

	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	# pattern.append(Vector2(-world.gap, 0))
	# pattern.append(Vector2(0, world.gap))

func _process(_delta):
	updateHealth(-1)