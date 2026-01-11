extends DisplayTile

@onready var tooltip = $CanvasLayer/Control/TooltipPane

var greyed_out_shader_material

# Called when the node enters the scene tree for the first time.
func _ready():
	super()
	greyed_out_shader_material = ShaderMaterial.new()
	greyed_out_shader_material.shader = load("res://views/player_hud/action_button/grey_scale.gdshader")

func set_card(card_scene):
	super(card_scene)
	if scene:
		if sprite:
			tooltip.set_texture(sprite.texture,sprite_frame_count)
		tooltip.set_title(scene.card_info.card_name)
		tooltip.add_subtitle("Pack: " + ExpansionSet.display_string(scene.card_info.pack))
		tooltip.add_subtitle("Rarity: " + Rarity.display_string(scene.card_info.rarity))

		# Await a process frame so the size can be accurately reflected
		tooltip.visible = true
		await get_tree().process_frame
		tooltip.move(Vector2(20,-tooltip.get_height()-20))
		tooltip.visible = false
		tooltip.enabled = true

func set_selected(selected):
	var style;
	if selected:
		if $Panel/Count.text == "0":
			style = empty_selected_style
		else:
			style = selected_style
	else:
		style = unselected_style
	$Panel.add_theme_stylebox_override("panel",style)

func set_count(num):
	$Panel/Count.text=str(num);
	if num == 0:
		set_sprite_material(greyed_out_shader_material)
	else:
		set_sprite_material(null)

func display_tooltip():
	tooltip.visible = true

func clear_tooltip():
	tooltip.visible = false

func _on_panel_mouse_entered():
	if tooltip.enabled:
		display_tooltip()

func _on_panel_mouse_exited():
	if tooltip.enabled:
		clear_tooltip()

func clear():
	super()
	tooltip.clear()
