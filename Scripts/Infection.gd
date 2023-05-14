extends Area2D

var health = 3
var rng = RandomNumberGenerator.new()
var infection_inst
var spread_dir
var move_time_limit = 30
var spread_time_limit = 600
var kill_window = 30 # how long before the flashlight can damage this scene again
var countdown = move_time_limit
var s_countdown = spread_time_limit
var k_countdown = kill_window
var dist = 16
var can_spawn = false
var max_siblings_spawned = 10
var siblings_spawned = 0
var parent_node
var dummy = false

onready var adj_detector = $AdjacentDetector
onready var glow_area = $Glow/GlowArea
onready var col = $CollisionShape2D
# onready var player = get_tree().get_root().get_node("World/YSort/Player")


# Called when the node enters the scene tree for the first time.
func _ready():
	infection_inst = load("res://NPC/Infection.tscn") # get the infection instance
	adj_detector.set_collide_with_areas(true)
	adj_detector.add_exception(glow_area)
	parent_node = get_parent()
	rng.randomize()
	# print(position)
	
	
	# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	if dummy:
		return
	

	for item in get_overlapping_areas():
		# if item.name == "FlashlightArea" and k_countdown <= 0 and player.flashing:
		# 	health -= 1
		# 	# print(name + " got hit, " + str(health))f
		# 	k_countdown = kill_window
		pass
		
	
	# var space_state = get_world_2d().direct_space_state
	# adj_detector.cast_to = position + Vector2(0, -9)
	
	if countdown <= 0 and siblings_spawned != max_siblings_spawned:

		# if check_neighbours_empty():
		# 	set_deferred("monitorable", false)
		# 	set_deferred("monitoring", false)
		# 	col.set_deferred("disabled", true)
		# 	print("not used, " + name)
		# else:
		# 	set_deferred("monitorable", true)
		# 	set_deferred("monitoring", true)
		# 	col.set_deferred("disabled", false)
			
		var rand_dir = rng.randi_range(1, 100)
		can_spawn = true
		spread_dir = Vector2()

		# choose a random direction to spread in, prioritising advancing movement rather than downwards movement
		# 10% chance to go down, 25% chance to go any 3 other directions (75%), 15% chance to not spawn
		if rand_dir <= 10:
			spread_dir = Vector2(0, dist) # down
		elif rand_dir > 10 and rand_dir < 35:
			spread_dir = Vector2(dist, 0) # right
		elif rand_dir > 35 and rand_dir < 60:
			spread_dir = Vector2(-dist, 0) # left
		elif rand_dir > 60 and rand_dir < 85:
			spread_dir = Vector2(0, -dist) # up
		else:
			spread_dir = Vector2(0, -dist)
			can_spawn = false
		
		adj_detector.cast_to = spread_dir
		var pos = position + spread_dir

		# if adj_detector.is_colliding():
		if parent_node.posi.count(pos) != 0:
			# can't spawn, colliding
			# if adj_detector.get_collider().name == "FlashlightArea":
			# 	# can spawn in the flashlights area
			# 	spawn_infection(position + spread_dir)
			# 	spawned = true
			# else:
			if adj_detector.is_colliding():
				# print("colliding with " + adj_detector.get_collider().name + ", " + str(adj_detector.get_collider().get_position()))
				pass
		else:
			if can_spawn:
				if !adj_detector.is_colliding():
					if s_countdown <= 0:
						call_deferred("spawn_infection", pos)
						siblings_spawned += 1
					else:
						position = pos
						# print(position)
						# spawned = true
			else:
				# can spawn, bad roll
				# print("bad roll")
				pass
			

		countdown = move_time_limit
	else:
		countdown -= 1
		s_countdown -= 1
	
	
	if s_countdown <= 0:
		if can_spawn:
			if !adj_detector.is_colliding():
				call_deferred("spawn_infection", position + spread_dir)
				siblings_spawned += 1
				s_countdown = spread_time_limit
	

	k_countdown -= 1

	if (health <= 0):
		queue_free()

	# if get_overlapping_areas().size() != 0:
	# 		# if this node overlaps with another node, delete this one
	# 		# call_deferred("queue_free")
	# 		# queue_free()
	# 		pass
	
func spawn_infection(pos: Vector2):
	var infect = infection_inst.instance()
	parent_node.add_child(infect)
	infect.set_position(pos)
	parent_node.posi.append(pos)
	# print(str(parent_node.posi))

# returns true if pos is not in the parent's (core's) array of used positions
func check_position_empty(pos: Vector2):
	return parent_node.posi.count(pos) == 0

# returns true if all adjacent sides of this node are empty
func check_neighbours_empty():
	return check_position_empty(position + Vector2(0, dist)) and check_position_empty(position + Vector2(0, -dist)) and check_position_empty(position + Vector2(dist, 0)) and check_position_empty(position + Vector2(-dist, 0))

func _on_VisibilityNotifier2D_screen_exited():
	hide()
	pass # Replace with function body.


func _on_VisibilityNotifier2D_screen_entered():
	show()
	pass # Replace with function body.



