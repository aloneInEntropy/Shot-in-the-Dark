extends Area2D

onready var sprite = $Sprite
var proper_name

func _ready():
	# print(global_position)
	proper_name = name
	if name == "Bread":
		sprite.texture = load("res://Assets/Items/Sprites/bread.png")
	elif name == "Batteries":
		sprite.texture = load("res://Assets/Items/Sprites/batteries.png")
	elif name == "Cupcake":
		sprite.texture = load("res://Assets/Items/Sprites/cupcake.png")
	elif name == "Sweet":
		sprite.texture = load("res://Assets/Items/Sprites/sweet.png")
	elif name == "MetalParts":
		sprite.texture = load("res://Assets/Items/Sprites/metal-parts.png")
	elif name == "WaterBottle":
		sprite.texture = load("res://Assets/Items/Sprites/water-bottle.png")
	elif name == "Chicken":
		sprite.texture = load("res://Assets/Items/Sprites/chicken.png")
		
func _process(_delta):
	if name == "Bread":
		sprite.texture = load("res://Assets/Items/Sprites/bread.png")
	elif name == "Batteries":
		sprite.texture = load("res://Assets/Items/Sprites/batteries.png")
	elif name == "Cupcake":
		sprite.texture = load("res://Assets/Items/Sprites/cupcake.png")
	elif name == "Sweet":
		sprite.texture = load("res://Assets/Items/Sprites/sweet.png")
	elif name == "MetalParts":
		sprite.texture = load("res://Assets/Items/Sprites/metal-parts.png")
	elif name == "WaterBottle":
		sprite.texture = load("res://Assets/Items/Sprites/water-bottle.png")
	elif name == "Chicken":
		sprite.texture = load("res://Assets/Items/Sprites/chicken.png")