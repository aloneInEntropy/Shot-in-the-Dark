extends Control

var dialog = [
	"...Bee?",
	"Bee! Is that you? Is that really you?",
	"Oh, God. I've finally found someone, thank fuck..."
]

var dialog_index = 0
var is_dialog_finished = false

func _ready():
	load_dialog()

func _process(_delta):
	$Continue.visible = is_dialog_finished
	if Input.is_action_pressed("ui_accept"):
		if is_dialog_finished:
			load_dialog()
		
	
func load_dialog():
	if dialog_index < dialog.size():
		is_dialog_finished = false
		$RichTextLabel.bbcode_text = dialog[dialog_index]
		$RichTextLabel.percent_visible = 0
		# load the dialog in character by character 
		$Tween.interpolate_property(
			$RichTextLabel, "percent_visible", 0, 1, 1, 
			Tween.TRANS_LINEAR, Tween.EASE_IN_OUT
		)
		$Tween.start()
	else:
		queue_free()
	dialog_index += 1


func _on_Tween_tween_completed(_object:Object, _key:NodePath):
	is_dialog_finished = true
