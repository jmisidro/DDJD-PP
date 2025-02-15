extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -900.0
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


func _physics_process(delta: float) -> void:
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
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	# The last parameter of the move_toward function, changes the drag that exists when a player moves, higher value, immediately stops the player
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, 25)

	move_and_slide()

	var isLeft = velocity.x < 0 
	animated_sprite_2d.flip_h = isLeft
