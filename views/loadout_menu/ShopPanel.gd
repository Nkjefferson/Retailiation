extends Panel

signal sig_sell
signal sig_update_shop
var in_focus : bool = false

# Current contents of the shop inventory
var current_inventory : Array[PackedScene]
@onready var inventory_grid = $Panel/ScrollContainer/ShopGrid
# holds the current value of the store that gets applied to the player
# when the accept button is clicked
var current_shop_value : int = 0
var toggle_shop : bool = false

var popup_size = 200

func _ready():
	$Panel.hide()
	calculate_store_value()

func _process(_delta):
	if Input.is_action_just_pressed("lclick") and in_focus:
		# Open up the store to view items inside
		if not toggle_shop:
			open_shop()
		else:
			$Panel.hide()
			toggle_shop = false
	elif Input.is_action_just_released("lclick") and in_focus:
		# "Sell" the item that is passed here
		sig_sell.emit()

func add_card_to_store(card_to_sell : PackedScene):
	if card_to_sell != null:
		current_inventory.append(card_to_sell)
		calculate_store_value()
		if toggle_shop:
			set_grid_from_inventory(current_inventory)

func sell_all_items():
	calculate_store_value()
	var retval = current_shop_value
	current_inventory.clear()
	clear_inventory_grid()
	calculate_store_value()
	sig_update_shop.emit()
	return retval

func calculate_store_value():
	current_shop_value = 0
	for card in current_inventory:
		# Replace 1 with whatever the cards value is
		var c = card.instantiate()
		self.add_child(c)
		current_shop_value += c.value
		c.queue_free()
	$ValueLabel.text = str(current_shop_value)

func update_shop_inventory():
	update_inventory_from_grid()
	var new_inventory : Array[PackedScene] = []
	for card in current_inventory:
		if card != null:
			new_inventory.append(card)
	current_inventory = new_inventory
	set_grid_from_inventory(current_inventory)
	calculate_store_value()
	sig_update_shop.emit()

func open_shop():
	set_grid_from_inventory(current_inventory)
	$Panel.show()
	toggle_shop = true
	sig_update_shop.emit()

func update_inventory_from_grid():
	var new_inventory : Array[PackedScene] = []
	for grid_element in inventory_grid.get_children():
		new_inventory.append(grid_element.get_node("SelectableTile").card_scene)
	current_inventory = new_inventory

func set_grid_from_inventory(inv:Array[PackedScene]):
	clear_inventory_grid()
	for i in range(0, inv.size()):
		var tile = load("res://views/loadout_menu/inventory_tile/inventory_tile.tscn").instantiate()
		inventory_grid.add_child(tile)
		tile.get_node("SelectableTile").set_sprite_scale(4)
		tile.get_node("SelectableTile").set_card(inv[i])
		tile.get_node("SelectableTile").set_scale(Vector2(0.5,0.5))


func clear_inventory_grid():
	for grid_element in inventory_grid.get_children():
		grid_element.queue_free()

func _on_mouse_entered():
	in_focus = true;

func _on_mouse_exited():
	in_focus = false;
