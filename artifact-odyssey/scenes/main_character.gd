extends CharacterBody2D

@export var MAX_HEALTH : int = 10
@export var SPEED: float = 400.0
@export var JUMP_VELOCITY: float = -900.0
@export var HURT_COOLDOWN: float = 0.3
@export var FLY_SPEED: float = 300.0
@export var DASH_SPEED: float = 1500.0
@export var DASH_DURATION: float = 0.2
@export var DASH_COOLDOWN: float = 1.5
@export var INVINCIBILITY_DURATION: float = 10.0
@onready var game_manager: Node = %GameManager
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var gun: Node2D = $Gun
@onready var graple: Node2D = $Graple
@onready var jump_audio = $JumpAudio

# Constants
const MAX_JUMPS = 2
const CHAIN_PULL = 100

# Basic
var isLeft: bool = false
var health: float
var playerHit: bool = false
var hurt_cooldown_timer: Timer

# Jumping
var can_jump = false			# Whether the player used their air-jump

# Jump Buffering
var jump_buffer_timer: Timer
var jump_buffer_time: float = 0.1  # Allow jumps within 100ms of pressing the button
var jump_buffered: bool = false

# Coyote Time
var coyote_time_timer: Timer
var coyote_time: float = 0.1  # Allow jumps for 100ms after leaving the ground
var can_coyote_jump: bool = false
var was_on_floor: bool = false

# Dash
var dash_timer: Timer
var cooldown_timer: Timer
var is_dashing: bool = false
var can_dash: bool = false
var dash_direction: int = 0

# Flying
var can_fly: bool = false
var flying: bool = false

# Invincibility
var invincibility_timer: Timer
var is_invincible: bool = false
var godmode: bool = false

# Double Jump 
var can_double_jump: bool = true
var jump_count: int = 0

# Gun 
var has_gun: bool = false

# Graple
var has_graple: bool = false
var chain_velocity := Vector2(0,0)

# Velocity Drag
var velocity_drag = 1

func _ready() -> void:
	health = MAX_HEALTH
	
	# Initialize Jump Buffer Timer
	jump_buffer_timer = Timer.new()
	jump_buffer_timer.wait_time = jump_buffer_time
	jump_buffer_timer.one_shot = true
	jump_buffer_timer.timeout.connect(_clear_jump_buffer)
	add_child(jump_buffer_timer)
	
	# Initialize Jump Coyote Timer
	coyote_time_timer = Timer.new()
	coyote_time_timer.wait_time = coyote_time
	coyote_time_timer.one_shot = true
	coyote_time_timer.timeout.connect(_end_coyote_time)
	add_child(coyote_time_timer)
	
	# Initialize Hurt Timer
	hurt_cooldown_timer = Timer.new()
	hurt_cooldown_timer.wait_time = HURT_COOLDOWN
	hurt_cooldown_timer.one_shot = true
	hurt_cooldown_timer.timeout.connect(_reset_hurt)
	add_child(hurt_cooldown_timer)
		
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
	playerHit = true
	hurt_cooldown_timer.start()  # Start cooldown before next hurt animation
	
	if health <= 0:
		print("You died. :(")
		game_manager.end_game()

		
func _clear_jump_buffer():
	jump_buffered = false
	
func _end_coyote_time():
	can_coyote_jump = false

func _reset_hurt():
	playerHit = false  # Allow the player to be hurt again

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
	
func grant_flight_ability():
	can_fly = true
	print("Player now has the ability to Fly!")

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
	if has_gun and Input.is_action_pressed("attack"):
		gun.shoot()
		
	# Flying
	if can_fly and Input.is_action_pressed("flying"):
		flying = !flying
		
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
	
	var move_vector = Vector2.ZERO
	
	# Flying movement
	if flying:
		if Input.is_action_pressed("jump"):
			velocity.y = -FLY_SPEED
		elif Input.is_action_pressed("down"):
			velocity.y = FLY_SPEED

	# Change velocity drag
	if (global_position.y < -2200):
		velocity_drag = 6
	else:
		velocity_drag = 1
	
	# Add the gravity and Animations
	if not is_on_floor():
		if not flying:
			velocity += get_gravity() * delta
		if velocity.y < 0:  # Moving upwards
			animated_sprite_2d.animation = "jumping"
		else:  # Moving downwards
			animated_sprite_2d.animation = "falling"
	elif abs(velocity.x) > 1:
		animated_sprite_2d.animation = "running"
	else:
		animated_sprite_2d.animation = "idle"

	if playerHit:
		animated_sprite_2d.animation = "hit"
		
	# Handle jump input buffering
	if Input.is_action_just_pressed("jump"):
		jump_buffered = true
		jump_buffer_timer.start()

	# Check if the player just left the ground (coyote time)
	if was_on_floor and not is_on_floor():
		can_coyote_jump = true
		coyote_time_timer.start()

	# Reset coyote time and jump count if the player lands
	if is_on_floor():
		can_coyote_jump = false
		coyote_time_timer.stop()
		jump_count = 0  # Allow both normal and double jump

	# Handle jumping (normal, coyote, and double jump)
	if jump_buffered:
		if is_on_floor() or can_coyote_jump:
			velocity.y = JUMP_VELOCITY
			jump_audio.play()
			jump_count = 1  # First jump used
			jump_buffered = false
			can_coyote_jump = false  # Consume coyote jump
		elif can_double_jump and jump_count < MAX_JUMPS:  # Allow double jump
			velocity.y = JUMP_VELOCITY
			jump_audio.play()
			jump_count += 1  # Use second jump
			jump_buffered = false  # Reset jump buffer

	was_on_floor = is_on_floor()  # Store previous ground state


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
		velocity.x = move_toward(velocity.x, 0, 50/velocity_drag)

	move_and_slide()

	animated_sprite_2d.flip_h = isLeft

	if not has_gun:
		return

	# Update gun direction based on isLeft
	$Gun.isLeft = isLeft
	$Gun.get_node("SpriteLeft").visible = isLeft
	$Gun.get_node("SpriteRight").visible = not isLeft
	gun.setup_direction(Vector2(-1, 0) if isLeft else Vector2(1, 0))
