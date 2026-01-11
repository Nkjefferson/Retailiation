extends Node2D

@export var game_over_scene : PackedScene
@export var passive_score_tick : float = 2.5
@export var gold : PackedScene = preload("res://environment/consumables/gold/gold.tscn")
@export var juice : PackedScene = preload("res://environment/consumables/gamer_juice/gamer_juice.tscn")
@export var pack : PackedScene = preload("res://environment/consumables/booster_pack/booster_pack.tscn")
@export var stage : PackedScene = preload("res://environment/stages/stage_one/stage_one.tscn")
@export var shop : PackedScene = preload("res://views/loadout_menu/loadout_menu.tscn")

signal score_update

var spawner_list = []
var score = 0
var score_tick_count = 0
var paused = false
var game_over = false
var rng
var coin_percent = 0.82
var juice_percent = 0.11
# This doesnt actually do, anything, its drop rate is calculated by whats leftover
# from the previous 2 things
var pack_percent = 0.07
var current_stage : Stage

# Called when the node enters the scene tree for the first time.
func _ready():
	set_stage(stage)
	MusicManager.set_chill_state(false)
	MusicManager.play_music("Retailiation")
	$Player.connect("death",_on_game_over)
	self.connect("score_update",$Player.player_hud._update_score)
	rng = RandomNumberGenerator.new()
	self.z_index = 0
	# Give some initial gold on the first level:
	GameState.player_currency = 10
	# Start the level
	start_level()

func _process(_delta):
	if Input.is_action_just_pressed("escape") and not game_over:
			pause_level()
	if Input.is_action_just_pressed("DEBUG_ACTION") and not game_over:
			_on_complete_level(null)

func start_level():
	$Player.spawn()
	current_stage.start()


func pause_level():
	var pause_screen = load("res://views/pause_menu/pause_menu.tscn").instantiate()
	self.add_child(pause_screen)
	pause_screen.connect("resume",resume_level)
	get_tree().paused = true

func load_shop():
	var shop_screen = load("res://views/loadout_menu/loadout_menu.tscn").instantiate()
	self.add_child(shop_screen)
	shop_screen.connect("continue_level", move_to_next_level)
	get_tree().paused = true

func stop_level():
	current_stage.stop()

func resume_level():
	MusicManager.set_chill_state(false)
	get_tree().paused = false

func set_stage(new_stage : PackedScene):
	var old_stage = current_stage
	current_stage = new_stage.instantiate()
	self.add_child(current_stage)
	current_stage.load_level(self)
	for node in get_children():
		if node.is_in_group("enemies") or node.is_in_group("consumable"):
			node.queue_free()
	if old_stage:
		old_stage.queue_free()
	$Player.global_position = current_stage.get_player_spawn_location()

func update_score(value):
	score += value
	score_update.emit(score)

func _on_enemy_death(enemy):
	update_score(enemy.score_value)

	var drop_chance = rng.randf()
	if drop_chance < coin_percent:
		var coin = gold.instantiate()
		self.call_deferred("add_child",coin)
		coin.spawn(enemy.global_position, enemy.gold_reward)
	elif drop_chance >= coin_percent and drop_chance < coin_percent+juice_percent:
		var j = juice.instantiate()
		self.call_deferred("add_child", j)
		j.spawn(enemy.global_position, 10)
	elif drop_chance >= coin_percent+juice_percent:
		var bp = pack.instantiate()
		self.call_deferred("add_child", bp)
		bp.spawn(enemy.global_position, 0)

func _on_complete_level(enemy):
	if enemy != null:
		update_score(enemy.score_value)
	$Player.save_state()
	self.call_deferred("load_shop")

func move_to_next_level():
	get_tree().paused = false
	self.call_deferred("set_stage",load("res://environment/stages/stage_two/stage_two.tscn"))
	self.call_deferred("start_level")

func _on_pack_collected_score(value):
	update_score(value);

func _on_score_timer_timeout():
	score_tick_count += 1
	update_score(int(passive_score_tick * score_tick_count))

func _on_game_over():
	if !game_over:
		game_over = true
		stop_level()
		var game_over_menu = game_over_scene.instantiate()
		self.add_child(game_over_menu)
		game_over_menu.update_metrics(score)
