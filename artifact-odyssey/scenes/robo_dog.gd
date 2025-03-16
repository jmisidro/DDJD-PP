extends Node2D

const SPEED = 120
var direction = -1
var speed_multiplier = 1
var is_sprinting = false

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right_bottom = $RayCastRightBottom
@onready var ray_cast_left_bottom = $RayCastLeftBottom
@onready var ray_cast_player_l = $RayCastLeftPlayer
@onready var ray_cast_player_r = $RayCastRightPlayer
@onready var walk_sound = $WalkSound
@onready var sprint_sound = $SprintSound

func _process(delta):
	# Check if the player is detected in front
	var player_detected = (ray_cast_player_r.is_colliding() and direction == 1) or (ray_cast_player_l.is_colliding() and direction == -1)

	if player_detected:
		start_sprinting()

	# Handle turning conditions
	if ray_cast_right.is_colliding() or !ray_cast_right_bottom.is_colliding():
		change_direction(-1)
		stop_sprinting()
	elif ray_cast_left.is_colliding() or !ray_cast_left_bottom.is_colliding():
		change_direction(1)
		stop_sprinting()

	# Move enemy
	position.x += direction * SPEED * delta * speed_multiplier

# Function to handle sprinting
func start_sprinting():
	if not is_sprinting:
		is_sprinting = true
		speed_multiplier = 4
		animated_sprite.animation = "running"
		walk_sound.stop()
		sprint_sound.play()

# Function to stop sprinting
func stop_sprinting():
	if is_sprinting:
		is_sprinting = false
		speed_multiplier = 1
		animated_sprite.animation = "walking"
		walk_sound.play()
		sprint_sound.stop()

# Function to handle direction change
func change_direction(new_direction):
	if direction != new_direction:
		direction = new_direction
		animated_sprite.flip_h = (direction == 1)  # Flip sprite for correct direction
		stop_sprinting()  # Reset sprint state when turning
