extends Node

var player_currency : int = 0
#TODO: Store as a CardInfo Resource instead of the scene itself
var player_loadout : Array[PackedScene] = [
	preload("res://characters/player/cards/basic_card/basic_card.tscn"),
	preload("res://characters/player/cards/piercing_card/piercing_card.tscn"),
	preload("res://characters/player/cards/triple_card/triple_card.tscn"),
	#null,
	preload("res://characters/player/cards/entangle_card/entangle_card.tscn"),
	preload("res://characters/player/cards/orbit_card/orbit_card.tscn")
]

func save_game_state(setting):
	var save_path = type_to_file_path(setting)
	if save_path == null:
		printerr("Failed to find settings path aborting save")
		return
	print("Saving to " + save_path)
	ResourceSaver.save(setting,save_path,ResourceSaver.FLAG_NONE)

func save_exists(path):
	return ResourceLoader.exists(path)

func load_game_state(setting):
	var save_path = type_to_file_path(setting)
	print("Loading: " + save_path)
	if save_path != null and save_exists(save_path):
		return ResourceLoader.load(save_path, "", ResourceLoader.CACHE_MODE_REPLACE)
	printerr("Failed to load " + save_path)
	return setting



func type_to_file_path(typename):
	if not typename.has_method("print_name"):
		printerr("This type does not have a print_name() function please implement one")
		return null
	return "user://" + typename.print_name() + ".tres"
