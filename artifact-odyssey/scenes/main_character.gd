extends CharacterBody2D

@export var MAX_HEALTH : int = 10
@export var SPEED: float = 400.0
@export var DASH_SPEED: float = 1000.0
@export var DASH_DURATION: float = 0.2
@export var DASH_COOLDOWN: float = 1.5
@export var INVINCIBILITY_DURATION: float = 6.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Node2D = $Gun
@onready var graple: Node2D = $Graple

const JUMP_VELOCITY = -900.0
const MAX_JUMPS = 2
const CHAIN_PULL = 100

# Basic
var isLeft: bool = false
var health: float

# Dash
var dash_timer: Timer
var cooldown_timer: Timer
var is_dashing: bool = false
var can_dash: bool = false
var dash_direction: int = 0

# Invincibility
var invincibility_timer: Timer
var is_invincible: bool = false
var godmode: bool = false

# Double Jump 
var can_double_jump: bool = false
var jump_count: int = 0

# Gun 
var has_gun: bool = true

# Graple
var has_graple: bool = true
var chain_velocity := Vector2(0,0)
var can_jump = false			# Whether the player used their air-jump


func _ready() -> void:
	health = MAX_HEALTH
		
	# Initialize Dash Timers
	dash_timer = Timer.new()
	dash_timer.wait_time = DASH_DURATION
	dash_timer.one_shot = true
	dash_timer.timeout.connect(_end_dash)
	add_child(dash_timer)
	
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = DASH_COOLDOWN
	cooldown_timer.one_shot = true
	cooldown_timer.timeout.connect(_reset_dash)
	add_child(cooldown_timer)
	
	# Initialize Invincibility Timer
	invincibility_timer = Timer.new()
	invincibility_timer.wait_time = INVINCIBILITY_DURATION
	invincibility_timer.one_shot = true
	invincibility_timer.timeout.connect(_end_invincibility)
	add_child(invincibility_timer)

func damage(dmg: int):
	if is_invincible or godmode:
		return
	
	health -= dmg
	
	if health <= 0:
		print("You died. :(")
		get_tree().reload_current_scene()

func start_invincibility():
	is_invincible = true
	invincibility_timer.start()

func _end_invincibility():
	is_invincible = false

func grant_gun_ability():
	has_gun = true
	print("Player now has the Gun!")
	
func grant_graple_ability():
	has_graple = true
	print("Player now has the Graple!")
	
func grant_double_jump_ability():
	can_double_jump = true
	print("Player now has the ability do Double Jump!")
	
func grant_dash_ability():
	can_dash = true
	print("Player now has the ability do Dash!")

func start_dash(direction):
	if direction == 0:
		return  # Prevent dashing in place (horizontal only)
	
	is_dashing = true
	dash_direction = direction
	dash_timer.start()
	
	# Play dash animation if you have one
	animated_sprite_2d.animation = "dashing"
	
	can_dash = false

func _end_dash():
	is_dashing = false
	cooldown_timer.start()  # Start cooldown before next dash

func _reset_dash():
	can_dash = true  # Allow dashing again


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and has_graple:
		if event.pressed:
			# We clicked the mouse -> shoot()
			graple.shoot(event.position - get_viewport().size * 0.5)
		else:
			# We released the mouse -> release()
			graple.release()


func _physics_process(delta: float) -> void:
	# Gun
	if Input.is_action_pressed("attack") and has_gun:
		gun.shoot()
		
	# Walking
	var walk = (Input.get_action_strength("right") - Input.get_action_strength("left")) * SPEED

	# Hook physics
	if graple.hooked:
		# `to_local(graple.tip_pos).normalized()` is the direction that the chain is pulling
		chain_velocity = to_local(graple.tip_pos).normalized() * CHAIN_PULL
		if chain_velocity.y > 0:
			# Pulling down isn't as strong
			chain_velocity.y *= 0.55
		else:
			# Pulling up is stronger
			chain_velocity.y *= 1.65
		if sign(chain_velocity.x) != sign(walk):
			# if we are trying to walk in a different
			# direction than the chain is pulling
			# reduce its pull
			chain_velocity.x *= 0.7
	else:
		# Not hooked -> no chain velocity
		chain_velocity = Vector2(0,0)
	velocity += chain_velocity

	
	# Add the gravity and Animations
	if not is_on_floor():
		velocity += get_gravity() * delta
		if velocity.y < 0:  # Moving upwards
			animated_sprite_2d.animation = "jumping"
		else:  # Moving downwards
			animated_sprite_2d.animation = "falling"
	elif abs(velocity.x) > 1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and (is_on_floor() or (can_double_jump and jump_count < MAX_JUMPS)):
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Reset jump count when landing
	if is_on_floor():
		jump_count = 1

	# Get the input direction and handle the movement/deceleration.
	var direction = Input.get_axis("left", "right")  # -1 (left) to 1 (right)
	
	# DASH
	if Input.is_action_just_pressed("dash") and can_dash and not is_dashing:
		start_dash(direction)

	if is_dashing:
		velocity.x = dash_direction * DASH_SPEED
	elif direction:
		velocity.x = direction * SPEED
		isLeft = direction < 0  # Update isLeft only when moving
	else:
		velocity.x = move_toward(velocity.x, 0, 25)

	move_and_slide()

	animated_sprite_2d.flip_h = isLeft

	if not has_gun:
		return

	# Update gun direction based on isLeft
	$Gun.isLeft = isLeft
	$Gun.get_node("SpriteLeft").visible = isLeft
	$Gun.get_node("SpriteRight").visible = not isLeft
	gun.setup_direction(Vector2(-1, 0) if isLeft else Vector2(1, 0))
