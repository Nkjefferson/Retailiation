class_name Enemy
extends CharacterBody2D

signal death

@export var move_speed : int = 100
@export var acceleration : int = 50
@export var health : int = 3
@export var damage : int = 10
@export var score_value : int = 100
@export var damage_tick_rate : float = 0.5
@export var gold_reward : int = 5
@export var sprite : AnimatedSprite2D = null

# global variable to hold the parent level scene
var parent


# variables for movement calcs
var destination : Vector2 = Vector2.ZERO
var direction : Vector2 = Vector2.ZERO
var moving : bool = true
var speed : float = 0.0
var health_bar_scene : PackedScene = preload("res://characters/enemies/enemy_assets/health_bar/health_bar.tscn")
var health_bar
var damage_indication_timer : Timer

# variables for pathing and navigation
@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
var colliding_with_wall : bool = false
# this sets the frequency of the timer to recalculate the A* path.
# setting this value lower increases accuracy of path but lowers performance
var navtimer_waittime : float = 0.25

# Called when the node enters the scene tree for the first time.
func _ready():
	parent = get_parent()
	if(sprite != null):
		$AnimatedSprite2D.play()
	self.add_to_group("enemies")
	set_motion_mode(MOTION_MODE_FLOATING)
	self.z_index = 2
	$NavTimer.wait_time = navtimer_waittime
	$NavTimer.one_shot = true
	nav_agent.max_neighbors = 5
	initialize_health_bar()

func initialize_health_bar():
	health_bar = health_bar_scene.instantiate()
	var health_bar_size = $AnimatedSprite2D.get_sprite_frames().get_frame_texture($AnimatedSprite2D.get_sprite_frames().get_animation_names()[0],0).get_size()
	self.add_child(health_bar)
	health_bar.set_custom_minimum_size(Vector2(health_bar_size.x, 4))
	health_bar.position.x -= health_bar_size.x / 2
	health_bar.position.y -= health_bar_size.y
	health_bar.init_health(health)

func take_damage(damage_dealer):
	$AnimatedSprite2D.material.set_shader_parameter("DamageTaken",true)
	$DamageIndicationTimer.start()
	health -= damage_dealer.damage
	speed -= damage_dealer.velocity.length()
	health_bar.health = health
	if health <= 0:
		death.emit(self)
		die()

func move_to_player(_delta):
	# Only use the A* pathfinding while colliding with a wall to help get unstuck
	# otherwise, use simple "go-to-player" system
	if colliding_with_wall:
		direction = to_local(nav_agent.get_next_path_position()).normalized()
	else:
		destination = parent.get_node("Player").position
		direction = position.direction_to(destination)

func _process(_delta):
	move_to_player(_delta)

func _physics_process(delta):
	speed += acceleration * delta
	if abs(speed) > move_speed:
		var modifier = 1
		if speed < 0:
			modifier = -1
		speed = move_speed * modifier
	velocity = direction * speed
	$AnimatedSprite2D.flip_h = direction.x < 0
	if moving:
		move_and_slide()
	check_collision()

# Generate A* path to players global position
func makepath():
	nav_agent.target_position = (parent.get_node("Player").global_position)

func check_collision():
	if $DamageTickTimer.is_stopped():
		for index in get_slide_collision_count():
			var collision = get_slide_collision(index)
			if collision.get_collider() and collision.get_collider().is_in_group("player"):
				# Apply damage to player
				collision.get_collider().take_damage(damage)
				$DamageTickTimer.set_wait_time(damage_tick_rate)
				$DamageTickTimer.start()
				# Drop speed to 0 to allow player to recover, remove when real hur mechanic is created
				speed = 0
				return
			# If the enemy is colliding with a Tilemap it indicates a wall or
			# stage hazard, enable A* pathfinding, and start navigation timer
			elif collision.get_collider() and collision.get_collider() is TileMap:
				colliding_with_wall = true
				makepath()
				if $NavTimer.is_stopped():
					$NavTimer.start()
				return

func die():
	queue_free()

func _on_nav_timer_timeout():
	if colliding_with_wall:
		makepath()
		$NavTimer.start()

# When the next node of the path is reached, untoggle enhanced pathfinding mode
# to save processing performance
func _on_navigation_agent_2d_waypoint_reached(_details):
	colliding_with_wall = false


func _on_damage_indication_timer_timeout():
	$AnimatedSprite2D.material.set_shader_parameter("DamageTaken",false)
