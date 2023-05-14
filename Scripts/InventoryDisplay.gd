extends GridContainer

var inventory = preload("res://Assets/Items/Inventory.tres")

func _ready():
	inventory.connect("items_changed", self, "_on_items_changed")
	update_inventory_display()
	# print("loaded")

# update the entire inventory
func update_inventory_display():
	for ind in inventory.items.size():
		update_inventory_slot_display(ind)

# update the inventory item at `item_index`
func update_inventory_slot_display(item_index):
	var inventory_slot_display = get_child(item_index)
	var item = inventory.items[item_index]
	inventory_slot_display.display_item(item)

# call `update_inventory_slot_display` for every slot in indexes
func _on_items_changed(indexes):
	for ind in indexes:
		update_inventory_slot_display(ind)
