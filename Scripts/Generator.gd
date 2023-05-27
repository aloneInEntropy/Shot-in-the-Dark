extends Area2D


signal game_over

var parts_needed = 5
var parts_obtained = 0

func _process(_delta):
	if parts_needed == parts_obtained:
		emit_signal("game_over")
		
