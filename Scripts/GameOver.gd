extends ColorRect

# onready var world = get_tree().get_root().get_node("World")
# onready var welcome_screen = world.gui.get_node("Welcome")

onready var rtl = $WinOrLose

func _process(_delta):
	if visible:
		if Input.get_action_strength("ui_accept") != 0:
			get_tree().paused = true
			# visible = false
			# var welcome_screen = world.get_node("GUI").get_node("Welcome")
			# welcome_screen.visible = true
	pass
