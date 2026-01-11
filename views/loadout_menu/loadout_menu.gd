extends CanvasLayer

signal continue_level

# Inputs: Eventually replace this with importing from a linked inventory
@export var temp_loadout : Array[PackedScene]
@export var temp_inventory : Array[PackedScene]
@export var temp_starting_gold : int

@onready var shop_panel = $Layout/ShopPanel
@onready var inventory_grid = $Layout/HBoxContainer/InventoryPanel/ScrollContainer/InventoryGrid
@onready var player_gold_display = $Layout/ShopPanel/PlayerGoldLabel
# Local up to date versions of the inventory and loadout for the player
var loadout : Array[PackedScene] = []
var inventory : Array[PackedScene] = []
var player_wallet : int = 0
# Load these values in ready and DO NOT edit them, so that the 'cancel' button
# can reload the original player values
var original_loadout : Array[PackedScene] = []
var original_inventory : Array[PackedScene] = []

var inventory_focused = false

# Local variables to track tile selections
var last_selected_tile

# Called when the node enters the scene tree for the first time.
func _ready():
	# Ensure menu runs over stopped game
	process_mode = Node.PROCESS_MODE_ALWAYS
	# Load values from player
	loadout = GameState.player_loadout
	player_wallet = GameState.player_currency

	original_loadout = temp_loadout
	inventory = temp_inventory
	original_inventory = temp_inventory

	# Initialize various elements of screen
	set_hotkey_labels()
	set_action_bar_loadout(loadout)
	set_grid_from_inventory(inventory)
	player_gold_display.text = str(player_wallet)

	# Connect Signals
	for ability_card in $Layout/Hotbar.get_children():
		# Connect the selection panel to the hotbar tiles
		ability_card.get_node("SelectableTile").connect("sig_take",_take_card_from_tile)
		ability_card.get_node("SelectableTile").connect("sig_give",_give_card_to_tile)
		# Connect the info viewer to the hotbar tiles
		ability_card.get_node("SelectableTile").connect("sig_take",$Layout/HBoxContainer/InfoViewer._set_card)

	# Connect the SelectionPanel to the Shop
	shop_panel.connect("sig_sell",_sell_card)
	shop_panel.connect("sig_update_shop",_connect_shop_elements)

func _process(_delta):
	if Input.is_action_just_released("lclick") and inventory_focused:
		add_card_to_inventory_grid()

# Functions to manage the hotbar/action bar
func set_hotkey_labels():
	var i = 2
	for ability_card in $Layout/Hotbar.get_children():
		ability_card.get_node("HotkeyLabel").text = InputMap.action_get_events("ActionButton" + str(i))[0].as_text().get_slice(" ",0)
		i+=1

func set_action_bar_loadout(ldt:Array[PackedScene]):
	#TODO: Update how the loadout menu enumerates, this is dumb
	for i in range(1,ldt.size()):
		if ldt[i]:
			$Layout/Hotbar.get_node("Hotbar_Tile" + str(i+1)).get_node("SelectableTile").set_card(ldt[i])

# Functions to manage the inventory grid
func set_grid_from_inventory(inv:Array[PackedScene]):
	clear_inventory_grid()
	for i in range(0, inv.size()):
		var tile = load("res://views/loadout_menu/inventory_tile/inventory_tile.tscn").instantiate()
		inventory_grid.add_child(tile)
		# Connect the selection panel to the Inventory tiles
		tile.get_node("SelectableTile").connect("sig_take",_take_card_from_tile)
		tile.get_node("SelectableTile").connect("sig_give",_give_card_to_tile)
		# Connect the info viewer to the Inventory tiles
		tile.get_node("SelectableTile").connect("sig_take",$Layout/HBoxContainer/InfoViewer._set_card)
		tile.get_node("SelectableTile").set_card(inv[i])

func sync_inventory_grid():
	update_inventory_from_grid()
	var new_inventory : Array[PackedScene] = []
	for card in inventory:
		if card != null:
			new_inventory.append(card)
	inventory = new_inventory
	set_grid_from_inventory(inventory)

func clear_inventory_grid():
	for grid_element in inventory_grid.get_children():
		grid_element.queue_free()

func update_inventory_from_grid():
	var new_inventory : Array[PackedScene] = []
	for grid_element in inventory_grid.get_children():
		new_inventory.append(grid_element.get_node("SelectableTile").card_scene)
	inventory = new_inventory

# Functions to manage shop interactions
func _sell_card():
	var tile = last_selected_tile
	if tile != null:
		last_selected_tile = null
		shop_panel.add_card_to_store(tile.card_scene)
		tile.set_card(null)
		# Update inventory array, and then remove the clean up grid
		sync_inventory_grid()

func _connect_shop_elements():
	for element in shop_panel.inventory_grid.get_children():
		# Connect the selection panel to the hotbar tiles
		if not element.get_node("SelectableTile").is_connected("sig_take",_take_card_from_tile):
			element.get_node("SelectableTile").connect("sig_take",_take_card_from_tile)
		if not element.get_node("SelectableTile").is_connected("sig_take",_take_card_from_tile):
			element.get_node("SelectableTile").connect("sig_give",_give_card_to_tile)
		if not element.get_node("SelectableTile").is_connected("sig_take",$Layout/HBoxContainer/InfoViewer._set_card):
			element.get_node("SelectableTile").connect("sig_take",$Layout/HBoxContainer/InfoViewer._set_card)

# Functions to manage interactions between the CurrentSelectionPanel and the
# other elements on screen
func _take_card_from_tile(source):
	if source.card_scene != null:
		$CurrentSelectionPanel.card_scene = source.card_scene
		$CurrentSelectionPanel.update_card()
		last_selected_tile = source

func _give_card_to_tile(dest):
	if last_selected_tile != null:
		if dest != last_selected_tile and last_selected_tile.get_parent().get_parent().name != "ShopGrid":
			if $CurrentSelectionPanel.card_scene != null:
				last_selected_tile.set_card(null)
				last_selected_tile.set_card(dest.card_scene)
				dest.set_card(null)
				dest.set_card($CurrentSelectionPanel.card_scene)
				sync_inventory_grid()
		$CurrentSelectionPanel.clear_card()
	last_selected_tile = null

func add_card_to_inventory_grid():
	if $CurrentSelectionPanel.card_scene != null:
		last_selected_tile.set_card(null)
		if last_selected_tile.get_parent().get_parent().name == "ShopGrid":
			shop_panel.update_shop_inventory()
		last_selected_tile = null
		sync_inventory_grid()
		inventory.append($CurrentSelectionPanel.card_scene)
		set_grid_from_inventory(inventory)

func save_state() -> void:
	# Save currency state
	GameState.player_currency = player_wallet
	# Update new loadout
	var i = 1
	for slot in $Layout/Hotbar.get_children():
		var new_card : PackedScene = null
		if !slot.get_node("SelectableTile").is_empty():
			new_card = slot.get_node("SelectableTile").card_scene
		GameState.player_loadout[i] = new_card
		i+=1

func _on_accept_button_pressed():
	# Remove everything in the store's inventory and add the value to the players
	# cash money
	var shop_val = shop_panel.sell_all_items()
	player_wallet += shop_val
	player_gold_display.text = str(player_wallet)

func _on_cancel_button_pressed():
	pass # Replace with function body.

func _on_inventory_panel_mouse_entered():
	inventory_focused = true

func _on_inventory_panel_mouse_exited():
	inventory_focused = false

func _on_continue_button_pressed() -> void:
	save_state()
	continue_level.emit()
	queue_free()
