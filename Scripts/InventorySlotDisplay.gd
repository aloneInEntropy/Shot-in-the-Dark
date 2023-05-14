extends CenterContainer

onready var item_texture_rect = $ItemTextureRect

func display_item(item):
	if item is Item:
		item_texture_rect.texture = item.texture
	else:
		item_texture_rect.texture = load("res://Assets/Items/Sprites/Empty.png")
	
func get_selected_data(_position):
	var _item_index = get_index()
	# var item = inventory.swap_items(item_index)
	pass