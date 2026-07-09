extends Control

@onready var sprite_panel = $VBoxContainer/SpritePanel
@onready var value_label = $VBoxContainer/PriceTag/ValueLabel

var current_item
var current_value : int = 0
var sprite : Sprite2D
var sprite_scl : int = 5

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func initialize(item, value : int):
	current_item = item
	current_value = value
	# Update sprites, labels, and information
	value_label.set_text(str(current_value))
	
	if current_item.sprite != null:
		sprite = Sprite2D.new()
		sprite.texture = current_item.sprite
		sprite.position += sprite_panel.size/2
		sprite.scale = Vector2(sprite_scl, sprite_scl)
		sprite_panel.add_child(sprite)
	else:
		printerr("Shop item does not have an associated sprite to display")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
