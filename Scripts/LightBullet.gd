extends Area2D

onready var world = get_tree().get_root().get_node_or_null("World")
onready var bullet_texture := preload("res://Assets/LightBullet_2_16.png")
onready var my_scale := scale

var pattern := {} # a dictionary, where the key is the pattern vector and the value is an array of the sprite and collider at that local point
var velocity := Vector2(1, .5) # direction to move
var gap = 16 # 16 pixels
var t = 20 # 20 frames
var tt = 0
var can_die := false
# var rotation_diff := PI/2 

func _ready():
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)
	
	add_to_group("light_bullets")
	var tpattern = get_parent().pattern

	for p in tpattern:
		# add a sprite and collision for each point in the light bullet's pattern
		var ts := Sprite.new() # sprite
		ts.position = Vector2(p.x+int(gap/2), p.y+int(gap/2))
		ts.texture = bullet_texture
		var tshape := RectangleShape2D.new() # collider shape
		tshape.extents = Vector2(int(gap/2), int(gap/2))
		var tcoll := CollisionShape2D.new() # collider
		tcoll.shape = tshape
		tcoll.position = Vector2(p.x, p.y)
		pattern[p] = [ts, tcoll]

		add_child(ts)
		ts.add_to_group("bullet_sprites")
		add_child(tcoll)
		tcoll.add_to_group("bullet_colliders")

func _physics_process(_delta):
	tt += 1
	tt = wrapf(tt, 0, t)
	if tt == 0:
		position += velocity.normalized()*gap
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)

	for pb in pattern:
		if pb+global_position in world.light_illegal:
			remove_from_pattern(pb)


# add a point to the bullet pattern
func add_to_pattern(v: Vector2):
	var ts := Sprite.new() # sprite
	ts.position = Vector2(v.x+int(gap/2), v.y+int(gap/2))
	ts.texture = bullet_texture
	var tshape := RectangleShape2D.new() # collider shape
	tshape.extents = Vector2(int(gap/2), int(gap/2))
	var tcoll := CollisionShape2D.new() # collider
	tcoll.shape = tshape
	pattern[v] = [ts, tcoll]
	add_child(ts)
	add_child(tcoll)

# remove a point from the bullet pattern
func remove_from_pattern(v: Vector2):
	if can_die:
		pattern[v][0].queue_free()
		pattern[v][1].queue_free()
		# for bs in get_tree().get_nodes_in_group("bullet_sprites"):
		# 	if bs.position == Vector2(v.x+int(gap/2), v.y+int(gap/2)):
		# 		bs.queue_free()
		# 		# print("removed sprite at %s" % v)

		# for bc in get_tree().get_nodes_in_group("bullet_colliders"):
		# 	if bc.position == v:
		# 		bc.queue_free()
		# 		# print("removed collider at %s" % v)

		pattern.erase(v)


func _on_SuicideTimer_timeout():
	queue_free() # destroy self after 20 seconds if not already destroyed


func _on_ImmortalTimer_timeout():
	can_die = true
