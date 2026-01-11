extends DisplayTile

@export var card_scene : PackedScene = null
signal sig_take
signal sig_give

var in_focus : bool = false

func _process(_delta):
	if in_focus:
		if Input.is_action_just_pressed("lclick") and card_scene != null:
			set_selected(true)
			sig_take.emit(self)
		if Input.is_action_just_released("lclick"):
			sig_give.emit(self)

func set_card(card):
	card_scene = card
	update_sprite()

func is_empty() -> bool:
	return card_scene == null

func update_sprite():
	if card_scene != null:
		super.set_card(card_scene)
	else:
		$AnimationTimer.stop()
		if sprite != null:
			sprite.queue_free()

func _on_panel_mouse_entered():
	in_focus = true

func _on_panel_mouse_exited():
	in_focus = false
	set_selected(false)
