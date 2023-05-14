extends Node2D

# onready var cutscene_player = $CutscenePlayer
# onready var cts1 = $Cutscenes/cutscene_trigger_1
onready var item_spawn_container = $ItemSpawnPositions
onready var inventory = $GUI/InventoryContainer
onready var gui = $GUI
onready var player = $YSort/Player # player
onready var player_flashlight = $GUI/FlashlightRemaining
onready var generator = $YSort/Generator
onready var infection_tiles := $EnemyTileMap
var item_spawner = load("res://Scenes/Item.tscn")
var rng = RandomNumberGenerator.new()

var cutscenes_played = []
var spawn_positions = PoolVector2Array([
	Vector2(-328, -305), Vector2(248, -241), Vector2(-640, 78), Vector2(-760, -234), Vector2(-736, -458), Vector2(-776, -914), Vector2(88, -818), Vector2(96, -610), Vector2(-128, 102), Vector2(240, -194), Vector2(-168, -1090)
])
var spawn_positions_used = []
var item_spawn_max_timer = 600 # 10 seconds to spawn an item
var item_spawn_timer = item_spawn_max_timer
var item_names = ["Bread", "Batteries", "Cupcake", "Sweet", "MetalParts", "WaterBottle", "Chicken"]
var npc_names = ["Orion", "Petra", "Oasis", "Aurora", "Borealis", "Mark"]
var dead_npc_names = []
var is_inventory_open = false # is the inventory open
var inf_points = [] # all infection tile points

var extra # extra temporary info for general tasks


func _ready():
	rng.randomize()
	player_flashlight.visible = true

func _draw():
	# draw_circle(target - position, 10, Color8(0, 255, 0))	
	for p in inf_points:
		draw_circle(p, 5, Color8(255, 0, 0))
	# for p in player.flac.polygon:
	# 	draw_circle(p, 5, Color8(255, 0, 0))
	pass
	
func _process(_delta):
	# -------------------------------------------- spread control -------------------------------------------- #
	# var state = get_world_2d().direct_space_state
	for s in get_tree().get_nodes_in_group("spreaders"):
		s.setTarget(player.global_position)
		if !s.isSpreading():
			s.setGridInterval(2)
			s.setMaxClosestPoints(32)
			s.startSpread()
		# inf_points.append_array(s.getPoints())
	
	pass
	update()

func _physics_process(_delta):
	# -------------------------------------------- item control -------------------------------------------- #
	# print("stage 1")
	if spawn_positions_used.size() < spawn_positions.size():
		if item_spawn_timer <= 0:
		# print("stage 2")
		# instantiate a random items in any free spaces
			var item_instance = item_spawner.instance()
			item_spawn_container.add_child(item_instance)
			# print("stage 3")
			# while there is a free position
			var new_position = Vector2(spawn_positions[rng.randi_range(0, spawn_positions.size() - 1)])
			# print("stage 4")
			while spawn_positions_used.find(new_position) != -1:
				# pick a random position free position until you find it
				new_position = Vector2(spawn_positions[rng.randi_range(0, spawn_positions.size() - 1)])
			# print("stage 5")
			spawn_positions_used.append(new_position)
			item_instance.position = new_position

			# pick a random item using it's name as a key.
			# since duplicated items will attach extra characters to the name, set the "proper_name" first, so the item can be inferred using it, then set the item's name to the proper name.
			item_instance.proper_name = item_names[rng.randi_range(0, item_names.size()-1)]
			item_instance.name = item_instance.proper_name
			
			# print(item_instance.name + ", " + str(item_instance.position))
			# print(str(spawn_positions_used.size()) + ", " + str(spawn_positions.size()))
			item_spawn_timer = item_spawn_max_timer
		else:
			item_spawn_timer -= 1
		
	# print("stage 6")
	if item_spawn_timer < -100:
		item_spawn_timer = -1

	if !is_inventory_open:
		# if the inventory isn't open
		if Input.get_action_strength("ui_inventory") != 0:
			# open inventory
			# print("opening inventory")
			inventory.is_active(true)
			pass
	else:
		# if the inventory is already open
		inventory.is_active(false)
		# print("closing inventory")
		pass

	# -------------------------------------------- npc control -------------------------------------------- #
	if dead_npc_names.size() == npc_names.size():
		# all npcs dead, loss
		pass
	
	if !player.flashing: inf_points.clear()
		


# func _on_cutscene_trigger_1_body_entered(body:Node):
# 	if cutscenes_played.find(cts1.name) == -1:
# 		if (body.name == player.name):
# 			print("entered by " + body.name)
# 			cutscene_player.play("test")
# 			cutscenes_played.append(cts1.name)
# 	# otherwise, cutscene has already played.


func _on_Orion_no_health():
	dead_npc_names.append("Orion")
	var npc = $YSort/Orion
	npc.queue_free()
	
func _on_Petra_no_health():
	dead_npc_names.append("Petra")
	var npc = $YSort/Petra
	npc.queue_free()
	
func _on_Aurora_no_health():
	dead_npc_names.append("Aurora")
	var npc = $YSort/Aurora
	npc.queue_free()
		
func _on_Borealis_no_health():
	dead_npc_names.append("Borealis")
	var npc = $YSort/Borealis
	npc.queue_free()
			
func _on_Mark_no_health():
	dead_npc_names.append("Mark")
	var npc = $YSort/Mark
	npc.queue_free()	
				
func _on_Oasis_no_health():
	dead_npc_names.append("Oasis")
	var npc = $YSort/Oasis
	npc.queue_free()


func _on_Generator_game_over():
	# game won
	inventory.is_active(false)
	is_inventory_open = false
	var game_over_screen = gui.get_node("GameOver")
	game_over_screen.get_node("WinOrLose").text = "You Won!"
	game_over_screen.get_node("Subtitle").text = "Thank you for playing! (and now, absolutely nothing :3)"
	var dnn = "Dead characters: "
	for n in dead_npc_names:
		dnn = dnn + n + ", "
	game_over_screen.get_node("DeadChars").text = dnn
	game_over_screen.visible = true
	get_tree().paused = true
	player_flashlight.visible = false
	pass
	
	
func _on_Player_game_over():
	# game lost
	inventory.is_active(false)
	is_inventory_open = false
	var game_over_screen = gui.get_node("GameOver")
	game_over_screen.get_node("WinOrLose").text = "You Lost!"
	game_over_screen.get_node("Subtitle").text = "Thank you for playing! (and now, absolutely nothing)"
	var dnn = ""
	for n in dead_npc_names:
		dnn = dnn + n + ", "
	game_over_screen.get_node("DeadChars").text = dnn
	game_over_screen.visible = true
	get_tree().paused = true
	player_flashlight.visible = false
	pass

func cwsort(pts: PoolVector2Array):
	var p = Array(pts)
	var centre := Vector2()
	for pt in pts:
		centre.x += pt.x
		centre.y += pt.y
	centre.x /= pts.size()
	centre.y /= pts.size()
	extra = centre
	p.sort_custom(self, "sort_ccw")

func sort_ccw(p1: Vector2, p2: Vector2):
	return (p1 - extra).angle() < (p2 - extra).angle()
