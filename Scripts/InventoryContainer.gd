extends ColorRect


onready var item_outline = $ItemOutline
onready var extra_item_outline = $ExtraItemOutline
onready var temp_item = $TempItem
onready var inventory = preload("res://Assets/Items/Inventory.tres")
onready var world = get_tree().get_root().get_node("World")
onready var player = get_tree().get_root().get_node("World/Player")

onready var bread_instance = preload("res://Assets/Items/Bread.tres")
onready var cupcake_instance = preload("res://Assets/Items/Cupcake.tres")
onready var metal_parts_instance = preload("res://Assets/Items/MetalParts.tres")
onready var sweet_instance = preload("res://Assets/Items/Sweet.tres")
onready var water_bottle_instance = preload("res://Assets/Items/WaterBottle.tres")
onready var chicken_instance = preload("res://Assets/Items/Chicken.tres")


# 22 pixels apart
var selection_positions = [Vector2(116, 90), Vector2(138, 90), Vector2(160, 90), Vector2(182, 90), Vector2(204, 90)] 
var aux_position = Vector2(72, 90)
var player_index = 0
var index_lo = 0
var index_hi = 4
var movement_cooldown = 12
var movement_frames_left = movement_cooldown
var selected_item
var is_inventory_active = false
var held_item = null


func _ready():
	item_outline.position = selection_positions[0]
	extra_item_outline.position = aux_position
	temp_item.position = aux_position

func _process(_delta):
	if is_inventory_active:
		selected_item = inventory.items[player_index]

		if movement_frames_left <= 0:
			if (Input.get_action_strength("ui_right") != 0):
				if player_index < index_hi:
					player_index += 1
					movement_frames_left = movement_cooldown
						
			elif (Input.get_action_strength("ui_left") != 0):
				if player_index > index_lo:
					player_index -= 1
					movement_frames_left = movement_cooldown
					# print(player_index)
			else:
				movement_frames_left = -1 # prevent frames left from getting too low and causing an underflow error
				
		item_outline.position = selection_positions[player_index]
		movement_frames_left -= 1

		if held_item == null:
			temp_item.texture = null
		else:
			temp_item.texture = held_item.get_node("Sprite").texture

		if Input.get_action_strength("ui_cancel") != 0:
			# close inventory
			if held_item:
				held_item = null
			elif player.is_talking:
				# if the player is talking to an NPC but leaves without giving them anything, don't change the inventory
				player.is_talking = false
				player.npc_item = false
				player.player_npc_cancelled = true
			close_inventory()
		
		if Input.get_action_strength("ui_accept") != 0:
			# if held_item and held_item.has_item:
			# picking up item
			if player.is_picking:
				# take item
				inventory.set_item(player_index, load("res://Assets/Items/" + held_item.proper_name + ".tres"))
				print("accepting: " + held_item.proper_name)
				held_item.takeItem()
				held_item = null
			# giving item away
			elif player.is_talking:
				# give item
				# if the player can interact and they open the inventory
				player.npc_item = inventory.pop_item(player_index)
				player.player_npc_selected.get_parent().receive_item(player.npc_item)
				player.player_npc_cancelled = false
			elif player.at_generator:
				# drop (use) selected item on generator
				if inventory.items[player_index]:
					if inventory.items[player_index].name == "Metal Parts":
						inventory.pop_item(player_index)
						world.generator.parts_obtained += 1
						# close inventory
					else:
						print("the generator can't accept this! (%s)" % inventory.items[player_index])
			else:
				print("player accepted " + str(held_item) + " at unknown location")
			
			print("closing inv now")
			close_inventory()
						
						
func is_active(value):
	is_inventory_active = value
	get_tree().paused = value
	visible = value


func open_inventory():
	is_active(true)
	get_tree().get_root().get_node("World").is_inventory_open = true


func close_inventory():
	is_active(false)
	get_tree().get_root().get_node("World").is_inventory_open = false
