extends RigidBody2D

const BULLET = preload("res://scenes/enemy_bullet.tscn")

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

@export var shootSpeed = 1.0
@export var MAX_HEALTH := 10

var health: float
var canShoot: bool = true
var isLeft: bool = true
var is_dead: bool = false 
var death_timer: Timer

func _ready() -> void:
	health = MAX_HEALTH
	shoot_speed_timer.wait_time = 1.0 / shootSpeed
	sprite_left.visible = false
	sprite_right.visible = false
	
	# Initialize Death Timer
	death_timer = Timer.new()
	death_timer.wait_time = 2
	death_timer.one_shot = true
	death_timer.timeout.connect(_on_death_timer_timeout)
	add_child(death_timer)

func damage(dmg: int):
	if is_dead:
		return  # Don't process further damage if already dead

	health -= dmg
	print("damage received: ", dmg)

	if health <= 0:
		die()
	else:
		animated_sprite_2d.animation = "hurt"
		animated_sprite_2d.play()

func die():
	is_dead = true  # Prevent further animation resets
	print("Enemy Killed!")
	
	animated_sprite_2d.animation = "death"
	animated_sprite_2d.play()
		
	death_timer.start()  # Start the timer to remove the enemy

func _on_death_timer_timeout():
	freeze = true  # Stop all physics interactions
	collision_shape_2d.set_deferred("disabled", true)  # Disable collision properly
	
	minix.pop_treasure() # Drop Minix Book



func _process(delta: float) -> void:
	if is_dead:
		return

	var detected = false
	var shoot_direction = Vector2.ZERO

	if ray_cast_player_right.is_colliding():
		isLeft = false
		animated_sprite_2d.offset.x = 10
		detected = true
		shoot_direction = Vector2(1, 0)
	elif ray_cast_player_left.is_colliding():
		isLeft = true
		animated_sprite_2d.offset.x = -10
		detected = true
		shoot_direction = Vector2(-1, 0)

	if detected and canShoot:
		shoot(shoot_direction)

	# Flip sprite based on direction
	animated_sprite_2d.flip_h = isLeft

func shoot(direction: Vector2):
	canShoot = false
	if isLeft:
		sprite_left.visible = true
	else:
		sprite_right.visible = true
		
	animated_sprite_2d.animation = "shooting"
	shoot_speed_timer.start()

	var bulletNode = BULLET.instantiate()
	bulletNode.set_direction(direction)  # Ensure bullet flies in the correct direction
	get_tree().root.add_child(bulletNode)
	if isLeft:
		bulletNode.global_position = marker_left.global_position
	else:
		bulletNode.global_position = marker_right.global_position
		
	if animated_sprite_2d.animation_finished:
		animated_sprite_2d.animation = "default"

func _on_shoot_speed_timer_timeout() -> void:
	canShoot = true
	sprite_left.visible = false  # Hide gun after shooting cooldown
	sprite_right.visible = false
