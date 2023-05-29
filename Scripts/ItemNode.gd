extends Area2D

onready var sprite = $Sprite
onready var timer = $Timer
var rng = RandomNumberGenerator.new()
var proper_name
var has_item
# names of items, with duplicate names to mock probability
var item_names = ["Bread", "Batteries", "Cupcake", "Sweet", "MetalParts", "WaterBottle", "Chicken", "Batteries"] 

"""textures"""
var bread_texture = preload("res://Assets/Items/Sprites/bread.png") # bread texture
var batteries_texture = preload("res://Assets/Items/Sprites/batteries.png") # batteries texture
var cupcake_texture = preload("res://Assets/Items/Sprites/cupcake.png") # cupcake texture
var sweet_texture = preload("res://Assets/Items/Sprites/sweet.png") # sweet texture
var metal_texture = preload("res://Assets/Items/Sprites/metal-parts.png") # metal texture
var water_texture = preload("res://Assets/Items/Sprites/water-bottle.png") # water texture
var chicken_texture = preload("res://Assets/Items/Sprites/chicken.png") # chicken texture
var empty_texture = preload("res://Assets/Items/Sprites/Empty.png") # empty texture


func _ready():
	rng.randomize()
	loadRandomItem()
	
func _process(_delta):
	if has_item: timer.stop()
	
func loadRandomItem():
	proper_name = item_names[rng.randi_range(0, item_names.size()-1)]
	loadTexture(proper_name)
	has_item = true
			
func loadTexture(texture_name: String):
	if texture_name == "Bread":
		sprite.texture = bread_texture
	elif texture_name == "Batteries":
		sprite.texture = batteries_texture
	elif texture_name == "Cupcake":
		sprite.texture = cupcake_texture
	elif texture_name == "Sweet":
		sprite.texture = sweet_texture
	elif texture_name == "MetalParts":
		sprite.texture = metal_texture
	elif texture_name == "WaterBottle":
		sprite.texture = water_texture
	elif texture_name == "Chicken":
		sprite.texture = chicken_texture

func _on_Timer_timeout():
	loadRandomItem()
	
# take the item in this item holder
func takeItem():
	has_item = false
	proper_name = "EMPTY"
	sprite.texture = empty_texture
	timer.start()

