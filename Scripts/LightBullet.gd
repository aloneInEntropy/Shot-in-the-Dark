extends Area2D

onready var bullet_texture := preload("res://Assets/LightBullet_2_16.png")
onready var my_scale := scale

var pattern := PoolVector2Array()
var velocity := Vector2(1, .5) # direction to move
var gap = 16 # 16 pixels
var t = 20 # 20 frames
var tt = 0
# var rotation_diff := PI/2 

func _ready():
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)
	
	add_to_group("light_bullets")
	pattern = get_parent().pattern

	for p in pattern:
		# add a sprite and collision for each point in the light bullet's pattern
		var ts := Sprite.new() # sprite
		ts.position = Vector2(p.x+int(gap/2), p.y+int(gap/2))
		ts.texture = bullet_texture
		var tshape := RectangleShape2D.new() # collider shape
		tshape.extents = Vector2(int(gap/2), int(gap/2))
		var tcoll := CollisionShape2D.new() # collider
		tcoll.shape = tshape
		
		add_child(ts)
		add_child(tcoll)

func _physics_process(_delta):
	tt += 1
	tt = wrapf(tt, 0, t)
	if tt == 0:
		position += velocity.normalized()*gap
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)
	pass

func set_pattern(p: PoolVector2Array):
	pattern = p

func set_velocity(v: Vector2):
	velocity = v
	
func get_pattern():
	return pattern 

func get_velocity():
	return velocity

func shoot(angle: float):
	rotation = angle

func _on_SuicideTimer_timeout():
	queue_free() # destroy self after 20 seconds if not already destroyed
