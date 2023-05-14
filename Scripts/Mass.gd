extends Sprite

var img_texture
var image

func _ready():
	img_texture = ImageTexture.new()
	


func _physics_process(_delta):
	image = Image.new()
	image = load("res://NPC/Infection.png")
	img_texture.create_from_image(image)
	self.texture = img_texture