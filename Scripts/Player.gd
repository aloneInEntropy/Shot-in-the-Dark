extends KinematicBody2D

const MAX_SPEED = 100
const ACCELERATION = 800
const FRICTION = 600

var velocity = Vector2.ZERO

signal game_over

onready var ap = $AnimationPlayer # animation player
onready var at = $AnimationTree # animation tree
onready var ast = at.get("parameters/playback") # animation state
onready var spr = $Sprite # player sprite
onready var fl = $Flashlight # player flashlight
onready var fla = fl.get_node("FlashlightArea") # flashlight area
onready var flac = fla.get_node("FlashlightCollider") # flashlight collider
onready var intbox = $InteractBox # interaction box
onready var world = get_tree().get_root().get_node("World") # world
onready var gui = world.get_node("GUI") # gui
onready var item_names = world.item_names
onready var npc_names = world.npc_names

var flashlight_battery_remaining = 100 # flashlight battery remaining
var flashlight_battery_loss = 0 # the amount to decrease the flashlight battery by
var battery_loss_rate = 10 # decrease battery by `flashlight_battery_loss` amount every 10 frames
var battery_loss_rate_frame = battery_loss_rate # the current battery loss frame
var added_battery_amount = 45 # how much generic battery pickups increase the battery by

var can_item_interact = false # is the player in a position where they can interact with an item?
var can_npc_interact = false # is the player in a position where they can interact with an NPC?
var is_talking = false
var item_overlapping
var npc_overlapping
var player_item_selected
var player_npc_selected
var inventory_contents = [] # strings of each inventory item
var flashing = false
var npc_item = null
var player_npc_cancelled = false
var at_generator = false
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

	# if the flash key (Z) is pressed, toggle the flashlight's visibility
	if (Input.get_action_strength("ui_flash") == 0) or flashlight_battery_remaining == 0:
		fl.visible = false
		fla.monitorable = false
		flashing = false
		gui.get_node("Label").text = ""
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
			var tp = flac.polygon
			tp[0] = tp[0].rotated(get_angle_to((prev_angle)))
			tp[1] = tp[1].rotated(get_angle_to((prev_angle)))
			tp[2] = tp[2].rotated(get_angle_to((prev_angle)))
			gui.get_node("Label").text = str(tp)
		
	velocity = move_and_slide(velocity)
	
	if can_item_interact:
		# print("here")
		if Input.get_action_strength("ui_pick_up") != 0:
			if !item_overlapping.proper_name == "Batteries":
				world.spawn_positions_used.erase(item_overlapping.position)
				player_item_selected = item_overlapping
				world.inventory.is_active(true)
				world.inventory.held_item = player_item_selected
			else:
				# add to battery
				flashlight_battery_remaining = min(100, flashlight_battery_remaining + added_battery_amount)
				gui.get_node("FlashlightRemaining").set_battery(flashlight_battery_remaining)
				# print("up: " + str(flashlight_battery_remaining))
				world.spawn_positions_used.erase(item_overlapping.position)
				item_overlapping.queue_free()
				item_overlapping = null
				world.item_spawn_timer = world.item_spawn_max_timer
		else:
			pass
	# else:
	# 	gui.get_node("Label").text = ""
	
	if can_npc_interact:
		if Input.get_action_strength("ui_pick_up") != 0:
			player_npc_selected = npc_overlapping
			is_talking = true
			world.inventory.is_active(true)
			# now, the player has either the chosen item, or nothing

			if npc_item and !player_npc_cancelled:
				player_npc_selected.receive_item(npc_item)
		else:
			# gui.get_node("Label").text = ""
			pass
	# else:
	# 	gui.get_node("Label").text = ""

	battery_loss_rate_frame -= 1

	pass
	


func _on_Hurtbox_area_entered(area:Area2D):
	if "Infection" in area.name:
		emit_signal("game_over")


func _on_InteractBox_area_entered(area:Area2D):
	var item_name = ""
	if area.name == "Generator":
		at_generator = true
	elif "proper_name" in area:
		item_name = area.proper_name
	else:	
		item_name = area.name
	# print("entrered " + item_name)
	if item_name in item_names:
		can_item_interact = true
		item_overlapping = area
	elif item_name in npc_names:
		can_npc_interact = true
		npc_overlapping = area
		
		
func _on_InteractBox_area_exited(area:Area2D):
	var item_name = ""
	if area.name == "Generator":
		at_generator = false
	elif "proper_name" in area:
		item_name = area.proper_name
	else:	
		item_name = area.name
	# print("left " + item_name)
	if item_name in item_names:
		can_item_interact = false
		item_overlapping = null
	elif item_name in npc_names:
		can_npc_interact = false
		npc_overlapping = null

# func strip_instanciated_chars(phrase):
# 	if "@" in phrase:
# 		phrase = phrase.substr(1, phrase.length()-1)
# 	phrase.rstrip("0123456789")
# 	return phrase


# https://stackoverflow.com/a/14382692
# check if point `p` is inside triangle with points `v1`, `v2`, and `v3`
func inside_tri(p: Vector2, v1: Vector2, v2: Vector2, v3: Vector2) -> bool:
	var area := 0.5 *(-v2.y*v3.x + v1.y*(-v2.x + v3.x) + v1.x*(v2.y - v3.y) + v2.x*v3.y)
	var s := 1/(2*area)*(v1.y*v3.x - v1.x*v3.y + (v3.y - v1.y)*p.x + (v1.x - v3.x)*p.y)
	var t := 1/(2*area)*(v1.x*v2.y - v1.y*v2.x + (v1.y - v2.y)*p.x + (v2.x - v1.x)*p.y)

	return s > 0 and t > 0 and (1-s-t) > 0


