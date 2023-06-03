extends KinematicBody2D

const MAX_SPEED = 100
const ACCELERATION = 800
const FRICTION = 600

var velocity = Vector2.ZERO

signal game_over

onready var ap = $AnimationPlayer # animation player
onready var at = $AnimationTree # animation tree
onready var spr = $Sprite # player sprite
onready var fl = $Flashlight # player flashlight
onready var intbox = $InteractBox # interaction box
onready var floorbox = $FloorBox # floor detection box
onready var pickup_audio = $PickupAudio # pickup audio
onready var fl_audio = $FlashlightAudio # flashlight click audio
onready var fla = fl.get_node("FlashlightArea") # flashlight area
onready var flac = fla.get_node("FlashlightCollider") # flashlight collider
onready var world = get_tree().get_root().get_node("World") # world
onready var cam_pointer := $CameraPointer
onready var gui = world.get_node("GUI") # gui
onready var player_ui = gui.get_node("FlashlightRemaining")
onready var ast = at.get("parameters/playback") # animation state
onready var item_names = world.item_names
onready var npc_names = world.npc_names

# the floor the player is on
var floor_num := 1

var flashlight_battery_remaining = 100 # flashlight battery remaining
var flashlight_battery_loss = 0.5 # the amount to decrease the flashlight battery by
var battery_loss_rate = 10 # decrease battery by `flashlight_battery_loss` amount every 10 frames
var battery_loss_rate_frame = battery_loss_rate # the current battery loss frame
var added_battery_amount = 35 # how much generic battery pickups increase the battery by

var can_item_interact = false # is the player in a position where they can interact with an item?
var can_npc_interact = false # is the player in a position where they can interact with an NPC?
var is_picking = false # is the player interacting with an item
var is_talking = false # is the player interacting with an npc
var flashing = false # is the flashlight on
var player_npc_cancelled = false
var at_generator = false
var fl_toggled = false
var item_overlapping
var npc_overlapping
var player_item_selected
var player_npc_selected
var inventory_contents = [] # strings of each inventory item
var npc_item = null
var prev_angle := Vector2()

func _ready():
	# print(item_names[4])
	pass

func _process(_delta):
	# print("player: " + str(global_position))
	
	pass

func _physics_process(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left") 
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up") 
	input_vector = input_vector.normalized()
	

	if input_vector != Vector2.ZERO:
		at.set("parameters/Idle/blend_position", input_vector)
		at.set("parameters/Walk/blend_position", input_vector)
		ast.travel("Walk")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		prev_angle = global_transform.origin + velocity
	else:
		ast.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
		
		
	# fl.look_at(global_transform.origin + velocity) last one was changed for some reason. this is the correct line.
	fl.look_at(global_transform.origin + velocity) # rotates the flashlight to look at the player's last velocity.
	fl.rotation_degrees = wrapf(fl.rotation_degrees, 0, 360.0) # wrap rotation between 0 and 360
	
	# if the flash key (Z) is pressed, toggle the flashlight's visibility
	if (Input.get_action_strength("ui_flash") == 0) or flashlight_battery_remaining == 0:
		fl.visible = false
		fla.monitorable = false
		flashing = false
		gui.get_node("Label1").text = ""
	else:
		if flashlight_battery_remaining > 0:
			fl.visible = true
			fla.monitorable = true # allow the area2D to detect other area2Ds
			flashing = true
			if battery_loss_rate_frame <= 0:
				battery_loss_rate_frame = battery_loss_rate
				flashlight_battery_remaining -= flashlight_battery_loss
				# print("down: " + str(flashlight_battery_remaining))
				for item in fla.get_overlapping_areas(): 
					if "Infection" in item.name:
						if item.k_countdown <= 0:
							item.health -= 1
							pass
			gui.get_node("FlashlightRemaining").set_battery(flashlight_battery_remaining)

			# if the flashlight is no longer pointing at anything but Z is still held, turn update the text
			if fla.get_overlapping_areas().size() == 0: 
				pass
				
	if fl_toggled != flashing:
		fl_audio.play()
		fl_toggled = flashing

	player_ui.set_flashlight_icon(flashing)
	
	velocity = move_and_slide(velocity)
	
	if can_item_interact:
		# print("here")
		if item_overlapping.has_item:
			if Input.get_action_strength("ui_pick_up") != 0:
				pickup_audio.play()
				if item_overlapping.proper_name == "Batteries":
					# add to battery
					flashlight_battery_remaining = min(100, flashlight_battery_remaining + added_battery_amount)
					gui.get_node("FlashlightRemaining").set_battery(flashlight_battery_remaining)
					item_overlapping.takeItem()
					world.item_spawn_timer = world.item_spawn_max_timer
				else:
					# deal with item
					player_item_selected = item_overlapping
					is_picking = true
					world.inventory.held_item = player_item_selected
					world.inventory.open_inventory()
	else:
		is_picking = false

	if at_generator:
		if Input.get_action_strength("ui_pick_up") != 0:
			world.inventory.open_inventory()

	if can_npc_interact:
		if Input.get_action_strength("ui_pick_up") != 0:
			at_generator = false
			is_picking = false

			player_npc_selected = npc_overlapping
			is_talking = true
			print(is_picking)
			world.inventory.open_inventory()
			# print("inv closed; doing npc stuff")
			# now, the player has either the chosen item, or nothing
			# if npc_item and !player_npc_cancelled:
			# 	player_npc_selected.get_parent().receive_item(npc_item)
	else:
		is_talking = false

	battery_loss_rate_frame -= 1
	# update()
	pass
	
func _draw():
	# draw_circle(flac.polygon[0].rotated(get_angle_to((prev_angle))), 5, Color8(255, 0, 0))
	# draw_circle(flac.polygon[1].rotated(get_angle_to((prev_angle))), 5, Color8(255, 0, 0))
	# draw_circle(flac.polygon[2].rotated(get_angle_to((prev_angle))), 5, Color8(255, 0, 0))
	pass


# check the floor the player is on
func check_floor():
	var res = get_world_2d().get_direct_space_state().intersect_point(position, 32, [], 2, true, true)
	for d in res:
		if d["collider"] == world.floor_hall:
			# print("going to hall")
			world.set_floor(world.FLOOR_NUM_HALL)
			return
		elif d["collider"] == world.floor_ground:
			# print("going to ground")
			world.set_floor(world.FLOOR_NUM_GROUND)
			return


func _on_Hurtbox_area_entered(area:Area2D):
	if "Infection" in area.name:
		emit_signal("game_over")


func _on_InteractBox_area_entered(area:Area2D):
	# print("entering %s" % area.name)
	var item_name = ""
	if area.name == "Generator":
		at_generator = true
	elif "has_item" in area and area.has_item:
		item_name = area.proper_name
	else:	
		item_name = area.name
	# print("entrered " + item_name)
	if item_name in item_names:
		# print(item_name)
		can_item_interact = true
		item_overlapping = area
	elif item_name in npc_names:
		can_npc_interact = true
		npc_overlapping = area
		
		
func _on_InteractBox_area_exited(area:Area2D):
	# print("leaving %s" % area.name)
	var item_name = ""
	if area.name == "Generator":
		at_generator = false
	elif "proper_name" in area:
		item_name = area.proper_name
	else:	
		item_name = area.name
	# print("left " + item_name)
	if item_name in item_names or ("has_item" in area and !area.has_item):
		can_item_interact = false
		item_overlapping = null
	elif item_name in npc_names:
		can_npc_interact = false
		npc_overlapping = null

