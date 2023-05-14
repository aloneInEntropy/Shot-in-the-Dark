extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var p
var q
var t
var dist = 16
var posi = [position]
var spawn_timer = 3600
var spawn_countdown = spawn_timer


# Called when the node enters the scene tree for the first time.
func _ready():
	# print(transform.origin)
	
	p = preload("res://NPC/Infection.tscn") # get the infection instance

	q = p.instance()
	add_child(q) 
	q.set_position(Vector2(dist, 0))
	posi.append(q.position)
	
	q = p.instance()
	q.set_position(Vector2(-dist, 0))
	add_child(q) 
	posi.append(q.position)
	
	q = p.instance()
	q.set_position(Vector2(0, dist))
	add_child(q) 
	posi.append(q.position)
	
	q = p.instance()
	q.set_position(Vector2(0, -dist))
	add_child(q)
	posi.append(q.position)

	posi.sort()
	
	

# func spawn_infection():
	# var spawn_pos = get_spawn_position()
	
func _physics_process(_delta):
	if spawn_countdown <= 0:
		q = p.instance()
		add_child(q) 
		q.set_position(Vector2(dist, 0))
		posi.append(q.position)
		
		q = p.instance()
		q.set_position(Vector2(-dist, 0))
		add_child(q) 
		posi.append(q.position)
		
		q = p.instance()
		q.set_position(Vector2(0, dist))
		add_child(q) 
		posi.append(q.position)
		
		q = p.instance()
		q.set_position(Vector2(0, -dist))
		add_child(q)
		posi.append(q.position)

		posi.sort()

		spawn_countdown = spawn_timer
	
	spawn_countdown -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
