extends Area2D

onready var world = get_tree().get_root().get_node_or_null("World")
onready var sprite = $Sprite

var pattern := PoolVector2Array()
var gap := 16
var bullet := preload("res://Scenes/LightBullet.tscn")
var dir := Vector2(position.x+gap, position.y)
var t = 20 # 20 frames
var tt = 0
var can_shoot := false
var can_turn := false

func _ready():
	pattern.append(Vector2(0, 0))
	pattern.append(Vector2(world.gap, 0))
	pattern.append(Vector2(-world.gap, 0))
	pattern.append(Vector2(0, world.gap))
	pattern.append(Vector2(0, -world.gap))
	pattern.append(Vector2(world.gap, -world.gap))
	pattern.append(Vector2(-world.gap, world.gap))
	pattern.append(Vector2(world.gap, world.gap))
	pattern.append(Vector2(-world.gap, -world.gap))
	
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)

func _process(_delta):
	tt += 1
	tt = wrapf(tt, 0, t)
	if tt == 0:
		can_shoot = true
		can_turn = true

	if can_shoot and Input.get_action_strength("ui_select") != 0:
		var tbullet = bullet.instance()
		tbullet.velocity = dir
		add_child(tbullet)
		can_shoot = false

	if can_turn and Input.get_action_strength("ui_focus_next") != 0:
		dir = dir.rotated(deg2rad(45))
		sprite.rotation_degrees += 45
		can_turn = false

