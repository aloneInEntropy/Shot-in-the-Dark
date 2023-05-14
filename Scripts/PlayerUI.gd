extends Control

onready var prog = $ProgressBar

var battery_left = 100 setget set_battery
var max_battery = 100 setget set_max_battery

onready var label = $Label

func _process(_delta):
	prog.value = battery_left

func set_battery(value):
	battery_left = clamp(value, 0, max_battery)

func set_max_battery(value):
	max_battery = max(value, 1)

func _ready():
	battery_left = 100
