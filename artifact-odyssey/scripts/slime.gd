extends Node2D

const SPEED = 120
var direction = 1
var speed_multipler = 1

@onready var ray_cast_right = $RayCastRight
@onready var ray_cast_left = $RayCastLeft
@onready var animated_sprite = $AnimatedSprite2D
@onready var ray_cast_player_r = $RayCastPlayerRight
@onready var ray_cast_player_l = $RayCastPlayerLeft

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	speed_multipler = 1
	
	if (ray_cast_player_r.is_colliding() && direction == 1):
		speed_multipler = 2.5
	
	if (ray_cast_player_l.is_colliding() && direction == -1):
		speed_multipler = 2.5
		
	if ray_cast_right.is_colliding():
		direction = -1
		animated_sprite.flip_h = true
		
	if ray_cast_left.is_colliding():
		direction = 1
		animated_sprite.flip_h = false

	position.x += direction * SPEED * delta * speed_multipler
