extends "res://Scripts/NPC.gd"


func _ready():
	sprite.texture = load("res://Assets/Spritesheets/petra.png")
	accepted_foods = items # accept all foods
	rejected_foods = []
	powerup_foods = {"Sweet":15, "Cupcake":15}
	max_health = 100
	health = max_health

	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	# pattern.append(Vector2(-world.gap, 0))
	# pattern.append(Vector2(0, world.gap))

	intbox.name = name

func _process(_delta):
	updateHealth(-1)