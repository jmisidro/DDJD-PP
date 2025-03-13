extends CharacterBody2D

const BULLET = preload("res://scenes/enemy_bullet.tscn")

@export var PATROL_DISTANCE: float = 400.0
@export var SPEED: float = 500.0
@export var JUMP_VELOCITY: float = -900.0
@export var DETECTION_RANGE: float = 400.0

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var area_2d: Area2D = $Area2D
@onready var ray_cast_player_left: RayCast2D = $Area2D/RayCastPlayerLeft
@onready var ray_cast_player_right: RayCast2D = $Area2D/RayCastPlayerRight
@onready var shoot_speed_timer: Timer = $Gun/shootSpeedTimer
@onready var sprite_left: Sprite2D = $Gun/SpriteLeft
@onready var sprite_right: Sprite2D = $Gun/SpriteRight
@onready var marker_left: Marker2D = $Gun/MarkerLeft
@onready var marker_right: Marker2D = $Gun/MarkerRight
@onready var minix: Area2D = $Minix
@onready var jump_timer: Timer = $JumpTimer

@export var shootSpeed = 1.0
@export var MAX_HEALTH := 10

var health: float
var canShoot: bool = true
var isLeft: bool = true
var is_dead: bool = false 
var death_timer: Timer
var direction: int = 1
var starting_position: Vector2

func _ready() -> void:
	health = MAX_HEALTH
	shoot_speed_timer.wait_time = 1.0 / shootSpeed
	sprite_left.visible = false
	sprite_right.visible = false
	
	starting_position = global_position
	jump_timer = Timer.new()
	jump_timer.wait_time = randf_range(1.5, 3.0)
	jump_timer.timeout.connect(_on_jump_timer_timeout)
	add_child(jump_timer)
	jump_timer.start()
	
	# Initialize Death Timer
	death_timer = Timer.new()
	death_timer.wait_time = 2
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(death_timer)

func damage(dmg: int):
	if is_dead:
		return
	
	health -= dmg
	if health <= 0:
		die()
	else:
		animated_sprite_2d.animation = "hurt"
		animated_sprite_2d.play()
		
func die():
	is_dead = true
	animated_sprite_2d.animation = "death"
	animated_sprite_2d.play()
	death_timer.start()
	
func _on_death_timer_timeout():
	collision_shape_2d.set_deferred("disabled", true)
	minix.pop_treasure()


func _physics_process(delta: float) -> void:
	if is_dead:
		return
	
	# Apply gravity
	velocity += get_gravity() * delta
	
	var player_detected = false
	var player_position = null
	var shoot_direction = Vector2.ZERO
	
	# Check for player detection
	if ray_cast_player_right.is_colliding():
		isLeft = false
		animated_sprite_2d.offset.x = 10
		player_detected = true
		player_position = ray_cast_player_right.get_collision_point()
		shoot_direction = Vector2(1, 0)
	elif ray_cast_player_left.is_colliding():
		isLeft = true
		animated_sprite_2d.offset.x = -10
		player_detected = true
		player_position = ray_cast_player_left.get_collision_point()
		shoot_direction = Vector2(-1, 0)
	
	if player_detected and canShoot:
		shoot(shoot_direction)

	# Enemy Movement Logic
	if player_detected and global_position.distance_to(player_position) < DETECTION_RANGE:
		# Chase player if detected
		var chase_direction = sign(player_position.x - global_position.x)
		velocity.x = chase_direction * SPEED
		isLeft = (chase_direction < 0)  # Correctly set facing direction
	else:
		# Patrolling when player is not detected
		if global_position.x >= starting_position.x + PATROL_DISTANCE:
			direction = -1
		elif global_position.x <= starting_position.x - PATROL_DISTANCE:
			direction = 1
		velocity.x = direction * SPEED  # Apply patrol movement

	move_and_slide()

	# Flip sprite based on direction
	animated_sprite_2d.flip_h = isLeft

func _on_jump_timer_timeout() -> void:
	if not is_dead and is_on_floor():
		velocity.y = JUMP_VELOCITY  # Jumping
	jump_timer.wait_time = randf_range(2.0, 4.0)
	jump_timer.start()

func shoot(direction: Vector2):
	canShoot = false
	if isLeft:
		sprite_left.visible = true
	else:
		sprite_right.visible = true
	
	animated_sprite_2d.animation = "shooting"
	shoot_speed_timer.start()

	var bulletNode = BULLET.instantiate()
	bulletNode.set_direction(direction)
	get_tree().root.add_child(bulletNode)
	if isLeft:
		bulletNode.global_position = marker_left.global_position
	else:
		bulletNode.global_position = marker_right.global_position

	if animated_sprite_2d.animation_finished:
		animated_sprite_2d.animation = "default"

func _on_shoot_speed_timer_timeout() -> void:
	canShoot = true
	sprite_left.visible = false
	sprite_right.visible = false
