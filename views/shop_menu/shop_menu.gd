extends CanvasLayer

# Number of cards that should be stocked in the shop
@export var card_stock_size : int  = 3
# TODO: Tinkets and upgrades are not yet implemented, these are placeholders for now
# Number of trinkets that should be stocked in the shop
@export var trinket_stock_size : int = 2
# Number of upgrades that should be stocked in the shop
@export var upgrade_stock_size : int = 2

# Shop Weights (Should add up to 100)
@export var common_weight : int = 60
@export var uncommon_weight : int = 30
@export var rare_weight : int = 10

# Locally store database information, should only be updated once
var common_cards = {}; var uncommon_cards = {}; var rare_cards = {};

# Internal class to store items in the shop with their values for easy access
class ShopItem:
	var item
	var value : int
	
# Cards currently available in the shop
# The "item" variable of ShopItem will be of type CardInfo
var shop_cards : Array[ShopItem] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func populate_shop_items():
	select_cards()

# Choose X random cards from the database to populate the shop, and calculate their costs
# TODO: add upgrades/buffs/etc to these selections once they are designed and implemented 
func select_cards():
	# Update package globals only if they are not already defined
	if common_cards.is_empty() || uncommon_cards.is_empty() || rare_cards.is_empty():
		common_cards = CardDatabase.get_cards_by_rarity([Rarity.CardRarity.COMMON])
		uncommon_cards = CardDatabase.get_cards_by_rarity([Rarity.CardRarity.UNCOMMON])
		rare_cards = CardDatabase.get_cards_by_rarity([Rarity.CardRarity.RARE])
	# Empty list of cards before repopulating
	shop_cards.clear()
	# Very basic method of choosing which cards to populate in the shop, may be
	# worth re-investigating at a later date, also can currently have duplicates
	# appear in the shop which we may want to remove.
	for i in range(0, card_stock_size):
		var sel = randi() % 100
		var new_card = null
		if sel <= common_weight:
			new_card = get_random_card_from_dict(common_cards)
		elif sel <= common_weight + uncommon_weight:
			new_card = get_random_card_from_dict(uncommon_cards)
		else:
			new_card = get_random_card_from_dict(rare_cards)
		# TODO: Here is where you would add any modifiers to the card
		var new_shop_item = ShopItem.new()
		new_shop_item.item = new_card
		# TODO: value would theoretically be calculated based on card modifiers
		new_shop_item.value = Rarity.get_value(new_card.rarity)
		shop_cards.append(new_shop_item)

func get_random_card_from_dict(dict : Dictionary) -> CardInfo:
	return dict[dict.keys().pick_random()]

func _on_restock_button_pressed() -> void:
	select_cards()
	$ShopPane.initialize(shop_cards[0].item, shop_cards[0].value)

func _on_exit_shop_button_pressed() -> void:
	pass # Replace with function body.
