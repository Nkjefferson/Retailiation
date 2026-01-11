extends CanvasLayer

@onready var healthbar = $HUD/HealthBar
@onready var actionbar = $HUD/Actionbar

# Called when the node enters the scene tree for the first time.
func _ready():
	set_hotkey_labels()
	healthbar.init_health(100)

func set_hotkey_labels():
	for ability_card in actionbar.get_children():
		ability_card.get_node("Panel/HotkeyLabel").text = InputMap.action_get_events(ability_card.name)[0].as_text().get_slice(" ",0)

func set_action_bar_loadout(loadout:Array[CardSlot]):
	for i in range(0,loadout.size()):
		# Clear the space first to clean up anything that may have been lingering
		actionbar.get_node("ActionButton" + str(i+1)).clear()
		if loadout[i]:
			actionbar.get_node("ActionButton" + str(i+1)).set_card(loadout[i].card)

func _update_card_hotbar(index, count):
	var hotkey_labels = actionbar.get_children()
	hotkey_labels[index].set_count(count)

func _update_health_value(health):
	#healthbar.text = str(health) + "%"
	healthbar.health = health

func _update_score(score):
	$HUD/ScoreTicker/Value.text = str(score)

func _update_gold(gold):
	$HUD/CurrencyTicker/Value.text = str(gold)

func _unhandled_key_input(event):
	if event.is_action_pressed("ActionButton1"):
			$"HUD/Actionbar/ActionButton1".set_selected(true)
	if event.is_action_released("ActionButton1"):
			$"HUD/Actionbar/ActionButton1".set_selected(false)
	if event.is_action_pressed("ActionButton2"):
			$"HUD/Actionbar/ActionButton2".set_selected(true)
	if event.is_action_released("ActionButton2"):
			$"HUD/Actionbar/ActionButton2".set_selected(false)
	if event.is_action_pressed("ActionButton3"):
			$"HUD/Actionbar/ActionButton3".set_selected(true)
	if event.is_action_released("ActionButton3"):
			$"HUD/Actionbar/ActionButton3".set_selected(false)
	if event.is_action_pressed("ActionButton4"):
			$"HUD/Actionbar/ActionButton4".set_selected(true)
	if event.is_action_released("ActionButton4"):
			$"HUD/Actionbar/ActionButton4".set_selected(false)
	if event.is_action_pressed("ActionButton5"):
			$"HUD/Actionbar/ActionButton5".set_selected(true)
	if event.is_action_released("ActionButton5"):
			$"HUD/Actionbar/ActionButton5".set_selected(false)
