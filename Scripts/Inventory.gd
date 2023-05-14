extends Resource
class_name Inventory

signal items_changed(indexes)

export(Array, Resource) var items = [
	null, null, null, null, null
]

# add `item` to the index at `item_index` and return any item in that slot
func set_item(item_index, item):
	var prev_item = items[item_index]
	items[item_index] = item
	emit_signal("items_changed", [item_index])
	return prev_item

# swap the position of the item at `item_index` and `target_item_index`
func swap_items(item_index, target_item_index):
	var target_item = items[target_item_index]
	var item = items[item_index]
	items[target_item_index] = item
	items[item_index] = target_item
	emit_signal("items_changed", [item_index, target_item_index])

# remove the item at `item_index`
func remove_item(item_index):
	var prev_item = items[item_index]
	items[item_index] = null
	emit_signal("items_changed", [item_index])
	return prev_item
