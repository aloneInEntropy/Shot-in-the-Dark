extends Control

onready var world = get_tree().get_root().get_node("World")

func _ready():
	get_tree().paused = true

func _process(_delta):
	if Input.get_action_strength("ui_accept") != 0:
		visible = false
		get_tree().paused = false
		# var game_start = game.instance()
		# add_child(game_start)
	
	if visible:
		get_tree().paused = true

	pass