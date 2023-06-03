extends Node2D

# onready var cutscene_player = $CutscenePlayer
# onready var cts1 = $Cutscenes/cutscene_trigger_1
# onready var hallway_tiles := $Floor1/HallwayTileMap

# universal node variables
onready var illegal_tiles := $IllegalTileMap
onready var illegal_light_tiles := $LightBlockTileMap

# player variables
onready var player = $Player # player
onready var infection_light := $Player/InfectionLight
onready var gui = $GUI
onready var inventory = $GUI/InventoryContainer
onready var player_flashlight = $GUI/FlashlightRemaining

# floor variables
var FLOOR_NUM_HALL := 0
var FLOOR_NUM_GROUND := 1
var FLOOR_NUM_UPPER := 2
var FLOOR_NUM_BASEMENT := 3
var FLOOR_NUM_NULL := -1
onready var floor_hall := $Hall # floor 0
onready var floor_ground := $Floor1 # floor 1
onready var floor_upper := $Floor2 # floor 2
onready var floor_basement := $Basement # floor 3
onready var floor_current
onready var generator = floor_ground.get_node("YSort/Generator")
onready var item_spawn_container = floor_ground.get_node("ItemSpawnPositions")

# other variables
var rng = RandomNumberGenerator.new()
var gap := 16
var cutscenes_played = []
var item_names = ["Bread", "Batteries", "Cupcake", "Sweet", "MetalParts", "WaterBottle", "Chicken"]
var npc_names = ["Orion", "Petra", "Oasis", "Aurora", "Borealis", "Mark"]
var dead_npc_names = []
var is_inventory_open = false # is the inventory open
var inf_points = [] # all infection tile points
var temp_invalids = {} # all invalid points as keys, and their respective timers as values
var illegal = [] # all illegal points, that infection is never allowed to spread to
var light_illegal = [] # all illegal light areas, that light bullets are destroyed upon touching
var extra # extra temporary info for general tasks

# timer variables
var item_spawn_max_timer = 600 # 10 seconds to spawn an item
var item_spawn_timer = item_spawn_max_timer
export var temp_invalid_removal_countdown_player := 240 # time to wait before spreading to invalid points if killed by player
export var temp_invalid_removal_countdown_npc := 60 # time to wait before spreading to invalid points if killed by npc
var floor_check_timer := 60
var floor_check_timer_rate := floor_check_timer


func _ready():
	rng.randomize()
	player_flashlight.visible = true
	var inflight := get_viewport().size
	infection_light.scale = inflight/16

	illegal_tiles.visible = false
	illegal_light_tiles.visible = false
	for p in illegal_tiles.get_used_cells():
		illegal.append(Vector2(p.x*gap, p.y*gap))
	for p in illegal_light_tiles.get_used_cells():
		light_illegal.append(Vector2(p.x*gap, p.y*gap))
	print(illegal[4])
	print(light_illegal[4])

func _draw():
	# draw_circle(target - position, 10, Color8(0, 255, 0))	
	for p in inf_points:
		draw_circle(p, 5, Color8(255, 0, 0))
	# for p in player.flac.polygon:
	# 	draw_circle(p, 5, Color8(255, 0, 0))
	pass
	
func _process(_delta):
	# -------------------------------------------- spread control -------------------------------------------- #
	for s in get_tree().get_nodes_in_group("spreaders"):
		s.setTarget(player.global_position)
		if !s.isSpreading():
			s.setGridInterval(20)
			s.setMaxClosestPoints(128)
			s.startSpread()

	for p in temp_invalids.keys():
		temp_invalids[p] -= 1
		if temp_invalids[p] <= 0:
			temp_invalids.erase(p)

	if floor_check_timer_rate <= 0:
		player.check_floor()
		floor_check_timer_rate = floor_check_timer
	floor_check_timer_rate -= 1
	
	floor_ground.get_node("GroundCamera").global_position = player.global_position
	floor_hall.get_node("HallCamera").global_position = player.global_position

	# update()

	

func _physics_process(_delta):
	if !is_inventory_open:
		# if the inventory isn't open
		if Input.get_action_strength("ui_inventory") != 0:
			# open inventory
			# print("opening inventory")
			inventory.open_inventory()
			pass
	else:
		# if the inventory is already open
		inventory.close_inventory()
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


# set the current floor using a number indicator. floor numbers:
# - 0: outer hall
# - 1: ground floor
# - 2: first floor
# - 3: basement
# - -1: null
func set_floor(num: int):
	match num:
		FLOOR_NUM_NULL:
			floor_current = null
			# print("leaving floor %s" % player.floor_num)
		FLOOR_NUM_HALL:
			floor_current = floor_hall
			floor_hall.get_node("HallCamera").current = true
			player.cam_pointer.remote_path = floor_hall.get_node("HallCamera").get_path()
			# print("on floor: hall")
		FLOOR_NUM_GROUND:
			floor_current = floor_ground
			floor_ground.get_node("GroundCamera").current = true
			player.cam_pointer.remote_path = floor_ground.get_node("GroundCamera").get_path()
			# print("on floor: ground")
		FLOOR_NUM_UPPER:
			floor_current = floor_upper
		FLOOR_NUM_UPPER:
			floor_current = floor_basement
	player.floor_num = num


func _on_Hall_area_entered(area:Area2D):
	if area == player.floorbox: set_floor(FLOOR_NUM_HALL)


func _on_Hall_area_exited(area:Area2D):
	if area == player.floorbox: set_floor(FLOOR_NUM_NULL)


func _on_Floor1_area_entered(area:Area2D):
	if area == player.floorbox: set_floor(FLOOR_NUM_GROUND)


func _on_Floor1_area_exited(area:Area2D):
	if area == player.floorbox: set_floor(FLOOR_NUM_NULL)
