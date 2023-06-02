extends Control

onready var prog = $ProgressBar
onready var fl_icon = $FlashlightIcon

onready var fl_on_texture = preload("res://Assets/FlashlightIconOn.png")
onready var fl_off_texture = preload("res://Assets/FlashlightIconOff.png")

var battery_left = 100 setget set_battery
var max_battery = 100 setget set_max_battery

onready var label = $Label

func _process(_delta):
	prog.value = battery_left

func set_battery(value):
	battery_left = clamp(value, 0, max_battery)

func set_max_battery(value):
	max_battery = max(value, 1)

func set_flashlight_icon(value: bool):
	if value:
		fl_icon.texture = fl_on_texture
	else:
		fl_icon.texture = fl_off_texture

func _ready():
	battery_left = 100
