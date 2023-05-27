extends Node2D

# onready var cutscene_player = $CutscenePlayer
# onready var cts1 = $Cutscenes/cutscene_trigger_1
onready var item_spawn_container = $ItemSpawnPositions
onready var inventory = $GUI/InventoryContainer
onready var gui = $GUI
onready var player = $YSort/Player # player
onready var player_flashlight = $GUI/FlashlightRemaining
onready var generator = $YSort/Generator
onready var hallway_tiles := $HallwayTileMap
onready var infection_light := $YSort/Player/InfectionLight
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
var temp_invalids = [] # all invalid points
var temp_invalid_removal_countdown := 240 # wait 240 frames (4 secs) before spreading to invalid points
var temp_invalid_removal_countdown_rate := temp_invalid_removal_countdown
var extra # extra temporary info for general tasks


func _ready():
	rng.randomize()
	player_flashlight.visible = true
	var inflight := get_viewport().size
	infection_light.scale = inflight/16

func _draw():
	# draw_circle(target - position, 10, Color8(0, 255, 0))	
	for p in inf_points:
		draw_circle(p, 5, Color8(255, 0, 0))
	# for p in player.flac.polygon:
	# 	draw_circle(p, 5, Color8(255, 0, 0))
	pass
	
func _process(delta):
	if temp_invalid_removal_countdown_rate <= 0:
		temp_invalids = PoolVector2Array()
		temp_invalid_removal_countdown_rate = temp_invalid_removal_countdown
	# -------------------------------------------- spread control -------------------------------------------- #
	# var state = get_world_2d().direct_space_state
	for s in get_tree().get_nodes_in_group("spreaders"):
		s.setTarget(player.global_position)
		if !s.isSpreading():
			s.setGridInterval(16)
			s.setMaxClosestPoints(32)
			s.startSpread()
		# inf_points.append_array(s.getPoints())
	
	temp_invalid_removal_countdown_rate -= 1 * delta
	# update()
	pass

func _physics_process(_delta):
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
""" 
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
	return p

func sort_ccw(a: Vector2, b: Vector2):
	if (a.x - extra.x >= 0 && b.x - extra.x < 0): 
		return true
	if (a.x - extra.x < 0 && b.x - extra.x >= 0): 
		return false
	if (a.x - extra.x == 0 && b.x - extra.x == 0): 
	    if (a.y - extra.y >= 0 || b.y - extra.y >= 0): 
	        return a.y > b.y
	    return b.y > a.y
    

    # compute the cross product of vectors (extra -> a) x (extra -> b)
	var det = (a.x - extra.x) * (b.y - extra.y) - (b.x - extra.x) * (a.y - extra.y)
	if (det < 0): 
	    return true
	if (det > 0): 
	    return false	
	# points a and b are on the same line from the center
	# check which point is closer to the center
	var d1 = (a.x - extra.x) * (a.x - extra.x) + (a.y - extra.y) * (a.y - extra.y)
	var d2 = (b.x - extra.x) * (b.x - extra.x) + (b.y - extra.y) * (b.y - extra.y)
	return d1 > d2;
 """
