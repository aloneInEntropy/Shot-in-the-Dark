extends Area2D

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
	pattern.append(Vector2(gap, 0))
	pattern.append(Vector2(-gap, 0))
	pattern.append(Vector2(0, gap))
	
	position.x = stepify(position.x, gap)
	position.y = stepify(position.y, gap)

func _process(_delta):
	tt += 1
	tt = wrapf(tt, 0, t)
	if tt == 0:
		can_shoot = true
		can_turn = true

	if can_shoot and Input.get_action_strength("ui_flash") != 0:
		var tbullet = bullet.instance()
		tbullet.set_velocity(dir)
		add_child(tbullet)
		can_shoot = false

	if can_turn and Input.get_action_strength("ui_accept") != 0:
		dir = dir.rotated(deg2rad(45))
		# dir += Vector2(gap/4, gap/4)
		sprite.rotation_degrees += 45
		can_turn = false

