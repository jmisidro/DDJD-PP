extends CharacterBody2D

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var ray_cast_2d: RayCast2D = $RayCast2D

# Constants
const SPEED = 150.0
const PATROL_AREA = Vector2(200, 0) # Distance from the starting point to patrol
const CHASE_SPEED = 250.0

# Variables
var direction = 1 # 1 = right, -1 = left
var start_position
var is_chasing = false
var player = null

# Called when the node is added to the scene
func _ready() -> void:
	start_position = position

# Physics update
func _physics_process(delta: float) -> void:
	if is_chasing and player:
		# Chase the player
		var to_player = player.position - position
		velocity.x = sign(to_player.x) * CHASE_SPEED
		
		# Flip the sprite based on direction
		animated_sprite_2d.flip_h = velocity.x < 0
		
	else:
		# Patrol between the defined area
		velocity.x = direction * SPEED
		
		if position.x > start_position.x + PATROL_AREA.x:
			direction = -1
			animated_sprite_2d.flip_h = false
			
		elif position.x < start_position.x - PATROL_AREA.x:
			direction = 1
			animated_sprite_2d.flip_h = true

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
		animated_sprite_2d.animation = "idle"
		player = null
