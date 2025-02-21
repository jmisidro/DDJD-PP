extends Node2D

const SPEED = 120
var direction = -1
var speed_multipler = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_right_bottom = $RayCastRightBottom
@onready var ray_cast_left_bottom = $RayCastLeftBottom
@onready var ray_cast_player_l = $RayCastLeftPlayer
@onready var ray_cast_player_r = $RayCastRightPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if (ray_cast_player_r.is_colliding() && direction == 1):
		animated_sprite.animation = "running"
		speed_multipler = 4
	
	if (ray_cast_player_l.is_colliding() && direction == -1):
		animated_sprite.animation = "running"
		speed_multipler = 4
		
	if (ray_cast_right.is_colliding() || !ray_cast_right_bottom.is_colliding()):
		direction = -1
		speed_multipler = 1
		animated_sprite.animation = "walking"
		animated_sprite.flip_h = false
		
	if (ray_cast_left.is_colliding() || !ray_cast_left_bottom.is_colliding()):
		direction = 1
		speed_multipler = 1
		animated_sprite.animation = "walking"
		animated_sprite.flip_h = true

	position.x += direction * SPEED * delta * speed_multipler
