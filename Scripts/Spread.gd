extends Area2D

# onready variables
# onready var infection = preload("res://Scenes/Infection.tscn") # get the infection instance
onready var world = get_tree().get_root().get_node_or_null("World")
onready var player = world.get_node_or_null("Player") if world else null
onready var infection_tiles = $EnemyTileMap
onready var timer = $Timer
onready var audio_player = $AudioPlayer

# arrays
var points := PoolVector2Array() # all points
var op := PoolVector2Array() # all boundary points
var inners := PoolVector2Array() # all inner points
var closest := PoolVector2Array() # closest boundary points
var invalids := PoolVector2Array() # all points not allowed to spread to

# variables
export var POINT_LIMIT := 1000 # maximum number of points allowed for an individual spreader
export var grid_interval := 1
export var maxClosestPoints := 64
var gap := 16
var centre_point := Vector2()
var closest_point := Vector2(2000, 2000) # closest point to player
var closest_dist := 10000 # closest distance to player
var rng := RandomNumberGenerator.new()
export var target := Vector2()
var rLowerBound := 5
var rMiddleBound := 10
var rUpperBound := 100
var pgi := 1
var width = ProjectSettings.get_setting("display/window/size/width")
var height = ProjectSettings.get_setting("display/window/size/height")
# var width = 1000
# var height = 1000
var can_spread := false	# allow searching and spreading
var inf_points = []
var frame = 0

""" 
The main idea here is to use the study in grid_test.pde to store an array of Vector2s instead of an array of Area2Ds
to build an infection outwards from the Core object (here called Spread to differentiate it). Then, the Infection.png sprite
will be tiled across every point (where each tile's origin is the top-left corner of the tile, which would be that point) 
to simulate an expansion of one singular mass, rather than several smaller nodes.

prev test width/height: 960, 540
"""

# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("spreaders")
	points.append(Vector2(stepify(global_position.x, gap), stepify(global_position.y, gap)))
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)
	

func _process(_delta):
	frame = int(wrapf(frame, 0, 60))
	frame += 1
	checkDeath()
	if can_spread:
		# update()

		op = checkBoundary(points, op, gap)
		points.append_array(op)
		points = removeDuplicates(points)

		# target = get_viewport().get_mouse_position() - Vector2(width/2, height/2)

		if frame % grid_interval == 0:
			if !points.empty():
				if closest.empty():
					points = pathfind(points, target)
				else: 
					points.append_array(pathfind(closest, target))
					points = removeDuplicates(points)

		if points.size() > POINT_LIMIT:
			# print("limit reached; point removed" + str(points[0]))
			removePoint(points[0], world.temp_invalid_removal_countdown_npc)
		
		for p in points:
			# if (points.has(Vector2(p.x + gap, p.y + gap)) and
			# 	points.has(Vector2(p.x + gap, p.y)) and
			# 	points.has(Vector2(p.x, p.y + gap)) and
			# 	!inners.has(p) and
			# 	!op.has(p)):
			# 		inners.append(p)
			var tdist = p.distance_to(player.global_position)
			if tdist < closest_dist:
				closest_dist = tdist
				closest_point = p
			placeTile(p, 1)
			if roundToN(target, gap).is_equal_approx(p):
				grid_interval = 10000
			else: 
				grid_interval = pgi

			
			var res = get_world_2d().get_direct_space_state().intersect_point(p, 32, [], 2, false, true)
			for d in res:
				if player and player.flashing:
					# get all areas intersecting with the current point on collision layer 2
					# (doesn't seem to care about the collision layer, so be careful)
					if d["collider"] == player.fla:
						removePoint(p, world.temp_invalid_removal_countdown_player)
				if d["collider"].is_in_group("light_bullets"):
					for pp in d["collider"].pattern:
						removePoint(p+pp, world.temp_invalid_removal_countdown_npc)
						# print(pp)
						
		centre_point /= Vector2(points.size(), points.size()) # get the average position of all points
		# audio_player.global_position = closest_point - position
		# audio_player.play()
						
		if checkInside(target, points):
			# print(inners.has(Vector2(stepify(target.x, gap), stepify(target.y, gap))))
			# print("DIED " + str(Vector2(stepify(target.x, gap), stepify(target.y, gap))) + " " + str(rng.randi()))
			grid_interval = 10000
			# can_spread = false
		else: 
			grid_interval = pgi

		closest = findClosestPoints(op, target, maxClosestPoints)
		op = PoolVector2Array() # clear
		

func _physics_process(_delta):
	pass	


func _draw():
	draw_circle(closest_point - position, 10, Color8(0, 255, 0))	
	# draw_circle(target - position, 10, Color8(0, 255, 0))	
	# for p in points:
	# 	draw_circle(p - position, 2, Color8(255, 255, 255))
	# var tpts = Geometry.convex_hull_2d(points)
	# var v = tpts[0]
	# for p in tpts:
	# 	draw_line(v-global_position, p-global_position, Color.white, 3)
	# 	v = p
	pass


# find the k closest points to the target
func findClosestPoints(pts: PoolVector2Array, tgt: Vector2, k: int) -> PoolVector2Array:
	var tp := PoolVector2Array() # temp points
	var dists := PoolRealArray() # distances
	var entered := 0;

	for p in pts:
		if (entered >= k):
			# if array is full
			var m : float = maxInArray(dists)
			if (p.distance_to(tgt) < m):
				var ti := dists.find(m);
				dists.remove(ti);
				tp.remove(ti);
				entered = k - 1;
			else: 
				continue
		tp.append(p);
		dists.append(p.distance_to(tgt))
		entered += 1
	return tp



# This algorithm has a `k`% change to move towards the target, depending on it's position relative to the target. There is also a `j`% change to move in a random direction. This random direction has a `i`/2% change to be no direction, and `i`/2% change to be right/down, and an `i`% change to be left/up. This allows for variety in spread that can be controlled by changing the probabilities. A breadth-first can_spread would head straight for the target but may not be sufficiently random. The speed of a BFS implementation would still allow the speed to be controlled using the grid interval.
func pathfind(pts: PoolVector2Array, tgt: Vector2) -> PoolVector2Array:
	var tpvs := PoolVector2Array(pts) # store copy of pts
	
	for p in tpvs:
		var rnd_dir_x := rng.randi_range(0, rUpperBound)
		var rnd_dir_y := rng.randi_range(0, rUpperBound)
		var amnt_x := 0
		var amnt_y := 0

		# random x direction to move in
		if rnd_dir_x <= rLowerBound:
			if rnd_dir_x % 2 == 0:
				amnt_x = gap
			else:
				amnt_x = 0
		elif rnd_dir_x <= rMiddleBound:
			amnt_x = -gap
		else:
			if tgt.x >= p.x:
				amnt_x = gap
			else:
				amnt_x = -gap
		
		# random y direction to move in
		if rnd_dir_y <= rLowerBound:
			if rnd_dir_y % 2 == 0:
				amnt_y = gap
			else:
				amnt_y = 0
		elif rnd_dir_y <= rMiddleBound:
			amnt_y = -gap
		else:
			if tgt.y >= p.y:
				amnt_y = gap
			else:
				amnt_y = -gap

		var npv := Vector2(stepify(p.x+amnt_x, gap), stepify(p.y+amnt_y, gap))
		if !pts.has(npv) and !world.temp_invalids.has(npv) and !world.illegal.has(npv):
			pts.append(npv)

	return pts


# (See https://docs.godotengine.org/en/3.2/tutorials/2d/using_tilemaps.html#creating-a-tileset)
# Define the boundaries of the grid.
func checkBoundary(pts: PoolVector2Array, bp: PoolVector2Array, gdist: int) -> PoolVector2Array:
	for tpv in pts:
		var tx = tpv.x
		var ty = tpv.y
		var p1 := Vector2(tx - gdist, ty - gdist)
		var p2 := Vector2(tx, ty - gdist)
		var p3 := Vector2(tx + gdist, ty - gdist)
		var p4 := Vector2(tx + gdist, ty)
		var p5 := Vector2(tx + gdist, ty + gdist)
		var p6 := Vector2(tx, ty + gdist)
		var p7 := Vector2(tx - gdist, ty + gdist)
		var p8 := Vector2(tx - gdist, ty)
		# var p0 := Vector2(tx, ty)
		
		if (
			# +hor and +ver line check (tile 8)
			!p5 in pts and
			p6 in pts and
			p1 in pts and
			p2 in pts and
			p3 in pts and
			p4 in pts and
			p7 in pts and
			p8 in pts
			):
			if (!bp.has(tpv)):
				bp.append(tpv);
			
		if (
			# +hor and -ver line check (tile 3)
			!p3 in pts and
			p6 in pts and
			p1 in pts and
			p2 in pts and
			p5 in pts and
			p4 in pts and
			p7 in pts and
			p8 in pts
			):
			if (!bp.has(tpv)):
				bp.append(tpv);
			
		if (
			# -hor and +ver line check (tile 11)
			!p7 in pts and
			p6 in pts and
			p1 in pts and
			p2 in pts and
			p3 in pts and
			p4 in pts and
			p5 in pts and
			p8 in pts
			) :
			if (!bp.has(tpv)):
				bp.append(tpv);
			
		if (
			# -hor and -ver line check (tile 6)
			!p1 in pts and
			p6 in pts and
			p5 in pts and
			p2 in pts and
			p3 in pts and
			p4 in pts and
			p7 in pts and
			p8 in pts
			) :
			if (!bp.has(tpv)):
				bp.append(tpv);
			
		if (
			# (tile 16)
			!p4 in pts and
			!p5 in pts and
			!p6 in pts and
			p1 in pts and
			p2 in pts and
			p3 in pts and
			p7 in pts and
			p8 in pts
			) :
			if (!bp.has(tpv)) :
				bp.append(tpv);
			
		
		if (
			# verticals check (tiles 2, 12)
			p6 in pts and
			((p4 in pts) != (p7 in pts))
			) :
			# if (tx <= width - gap && tx >= 0 && ty <= height - gap && ty >= 0):
			if (!bp.has(tpv)):
				bp.append(tpv);
			
			if (!bp.has(p6)):
				bp.append(p6);
				
		if (
			# horiontals check (tiles 4, 10)
			(p4 in pts) && 
			((p6 in pts) != (p2 in pts))
			) :
			# if (tx <= width - gap && tx >= 0 && ty <= height - gap && ty >= 0):
			if (!bp.has(tpv)):
				bp.append(tpv);
			if (!bp.has(p4)):
				bp.append(p4);
	
	return bp


# max value in array
func maxInArray(arr):
	var m := -1.79769e308
	for p in arr:
		m = max(m, p)
	return m


# min value in array
func minInArray(arr):
	var m := 1.79769e308
	for p in arr:
		m = min(m, p)
	return m


# remove all duplicates from this array
func removeDuplicates(arr: PoolVector2Array) -> PoolVector2Array:
	var tmp := PoolVector2Array()
	for p in arr:
		if !tmp.has(p):
			tmp.append(p)
	return tmp


# enable this node to spread towards the target
func startSpread() -> void:
	can_spread = true

# disable this node's ability to spread
func stopSpread() -> void:
	can_spread = false

# check if this node is currently spreading
func isSpreading() -> bool:
	return can_spread

func getGridInterval():
	return grid_interval

func setGridInterval(s: int):
	pgi = s
	grid_interval = s
	# frame = s


# get an array of all points not allowed to be spread to
# func getInvalidPoints() -> PoolVector2Array:
# 	return world.invalids
	
	
# # set the points not allowed to be spread to
# func setInvalidPoints(npts: PoolVector2Array) -> void:
# 	world.invalids = PoolVector2Array(npts)
		

# get all points this node has spread to
func getPoints() -> PoolVector2Array:
	return points

# set the points this node has spread to
func setPoints(npts: PoolVector2Array) -> void:
	points = PoolVector2Array(npts)

# get all boundary points this node has spread to
func getBoundaryPoints() -> PoolVector2Array:
	return op

# set the boundary points this node has spread to
func setBoundaryPoints(npts: PoolVector2Array) -> void:
	op = PoolVector2Array(npts)


# get all inner points this node has spread to
func getInnerPoints() -> PoolVector2Array:
	return inners

# set the inner points this node has spread to
func setInnerPoints(npts: PoolVector2Array) -> void:
	inners = PoolVector2Array(npts)


# get the target this node is spreading towards
func getTarget() -> Vector2:
	return target


# set the target this node is spreading towards
func setTarget(tgt: Vector2) -> void:
	target = tgt

func getMaxClosestPoints():
	return maxClosestPoints

func setMaxClosestPoints(mcp: int):
	maxClosestPoints = mcp

# check if the target `t` is inside the spread boundary
func checkInside(t: Vector2, pts: PoolVector2Array) -> bool:
	return pts.has(Vector2(stepify(t.x, gap), stepify(t.y, gap)))

func roundToN(v: Vector2, n: int):
	return Vector2(stepify(v.x, n), stepify(v.y, n))

# places a tile with tile number `tn` at point `v`
func placeTile(v: Vector2, tn: int):
	if v in points:
		infection_tiles.set_cell(
			stepify((v.x-global_position.x), gap)/infection_tiles.cell_quadrant_size,
			stepify((v.y-global_position.y), gap)/infection_tiles.cell_quadrant_size,
			tn
		)
		infection_tiles.update_dirty_quadrants()
		return true
	return false

func removePoint(v: Vector2, t: float):
	var i := points.find(v)
	if i >= 0: 
		points.remove(i)
		infection_tiles.set_cell(
			stepify((v.x-global_position.x), gap)/infection_tiles.cell_quadrant_size,
			stepify((v.y-global_position.y), gap)/infection_tiles.cell_quadrant_size,
			-1
		)
		# start a frame timer for the removed point so it can't be spread to until the timer finishes
		world.temp_invalids[v] = t

func checkDeath():
	if points.size() == 0:
		print(name + " is destroyed!")
		queue_free()
