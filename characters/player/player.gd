extends CharacterBody2D

signal player_health_updated(int)
signal death

@export var max_speed : int  = 200
@export var acceleration : int = 700
@export var max_health : int = 100
@export var player_hud_scene : PackedScene
@export var marker_frames : SpriteFrames
@export var death_sound : Resource
@export var hurt_sound : Resource


var player_camera : Camera2D
var destination : Vector2 = Vector2.ZERO
var moving : bool = false
var alive : bool = true
var speed : float = 0.0
var health : int
@onready var player_hud = $PlayerHud
var marker : AnimatedSprite2D


func _ready():
	self.z_index = 2
	health = max_health
	self.add_to_group("player")
	set_motion_mode(MOTION_MODE_GROUNDED)

	# Inventory and signal management
	$Inventory.connect("update_card_count", player_hud._update_card_hotbar)
	$Inventory.connect("update_gold_amount", player_hud._update_gold)
	self.connect("player_health_updated",player_hud._update_health_value)
	# Push initial player health
	player_health_updated.emit(health)
	#player_hud.set_action_bar_loadout($Inventory.slots)
	#$Inventory.refresh_hotbar()
	#player_hud._update_gold($Inventory.gold)
	$AnimatedSprite2D.play("Idle")

	marker = AnimatedSprite2D.new()
	marker.sprite_frames = marker_frames
	marker.z_index = 3
	marker.play("default")
	get_parent().add_child.call_deferred(marker)
	marker.visible = false

func spawn():
	health = max_health
	player_health_updated.emit(health)
	$Inventory.update_from_gamestate()
	player_hud.set_action_bar_loadout($Inventory.slots)
	player_hud._update_gold($Inventory.gold)

func save_state():
	$Inventory.save_state()

func _process(_delta):
	var mouse_direction = position.direction_to(get_global_mouse_position()).x
	$AnimatedSprite2D.flip_h = mouse_direction < 0
	for i in range(0,5):
		if Input.is_action_just_pressed(("ActionButton" + str(i+1))):
			shoot(i)

func _physics_process(delta):
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		destination = get_global_mouse_position()
		marker.global_position = destination - Vector2(0,8)
		if !marker.visible:
			marker.visible = true
		moving = true
		$AnimatedSprite2D.play("Run")

	movement_loop(delta)

func movement_loop(delta):
	if moving == false:
		speed = 0
	else:
		speed += acceleration * delta
		if speed > max_speed:
			speed = max_speed
	velocity = position.direction_to(destination) * speed
	if position.distance_to(destination) > 5:
		move_and_slide()
	else:
		marker.visible = false
		moving = false
		$AnimatedSprite2D.play("Idle")

func shoot(slot):
	var target = get_global_mouse_position()
	var card_type = $Inventory.shoot(slot)
	if card_type != null:
		var c = card_type.instantiate()
		get_parent().add_child(c)
		c.spawn(self, target)
		MusicManager.play_sound_effect(c.throw_sound)

func take_damage(damage):
	if alive:
		$AnimatedSprite2D.material.set_shader_parameter("DamageTaken",true)
		$DamageIndicationTimer.start()
		health -= damage
		if health <= 0:
			$AnimatedSprite2D.material.set_shader_parameter("DamageTaken",false)
			alive = false
			health = 0
			$AnimatedSprite2D.play("Die")
			if death_sound:
				MusicManager.play_sound_effect(death_sound)
			else:
				printerr("No death SFX found in: ",self.name)
			self.set_physics_process(false)
			$CollisionShape2D.disabled=true
			await $AnimatedSprite2D.animation_finished
			death.emit()
		else:
			MusicManager.play_sound_effect(hurt_sound,20)
		player_health_updated.emit(health)


func heal(damage):
	health = clamp(health+damage, health, max_health)
	player_health_updated.emit(health)


func _on_damage_indication_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("DamageTaken",false)
