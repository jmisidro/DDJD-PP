extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D
@onready var patrol_area: Area2D = $PatrolArea

# Constants
const SPEED = 150.0
const PATROL_AREA = Vector2(400, 0) # Distance from the starting point to patrol
const CHASE_SPEED = 250.0

# Variables
var direction = 1 # 1 = right, -1 = left
var start_position
var is_chasing = false
var player = null

# Called when the node is added to the scene
func _ready() -> void:
	start_position = position
	ray_cast_2d.target_position = Vector2(50, 0)  # Facing right
	animated_sprite_2d.animation = "walking"
	animated_sprite_2d.flip_h = true

# Physics update
func _physics_process(delta: float) -> void:
	if is_chasing and player:
		# Calculate distance to player on the X axis
		var playerRight = player.position - position
				
		# Move towards the player based on their position
		if playerRight.x > 0:
			# Move to the right, but check patrol limits
			if position.x < start_position.x + PATROL_AREA.x:
				velocity.x = CHASE_SPEED
				animated_sprite_2d.flip_h = true
			else:
				velocity.x = 0  # Stop if at the patrol limit
		else:
			# Move to the left, but check patrol limits
			if position.x > start_position.x - PATROL_AREA.x:
				velocity.x = -CHASE_SPEED
				animated_sprite_2d.flip_h = false
			else:
				velocity.x = 0  # Stop if at the patrol limit

	# Patrol between the defined area if not chasing
	else:
		velocity.x = direction * SPEED
		
		# Check if the enemy is within the patrol area limits
		if position.x >= start_position.x + PATROL_AREA.x:  # Reached the right limit
			# Change direction to move left
			direction = -1
			animated_sprite_2d.flip_h = false
			ray_cast_2d.target_position = Vector2(-PATROL_AREA.x, 0)  # Pointing Left

		elif position.x <= start_position.x - PATROL_AREA.x:  # Reached the left limit
			# Change direction to move right
			direction = 1
			animated_sprite_2d.flip_h = true
			ray_cast_2d.target_position = Vector2(PATROL_AREA.x, 0)  # Pointing Right
		
	move_and_slide()

# Detection logic
func _on_Area2D_body_entered(body):
	if body.name == "Player" and ray_cast_2d.is_colliding():
		is_chasing = true
		animated_sprite_2d.animation = "running"
		player = body

func _on_Area2D_body_exited(body):
	if body.name == "Player":
		is_chasing = false
		animated_sprite_2d.animation = "walking"
		player = null
