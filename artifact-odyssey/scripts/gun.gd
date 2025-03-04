extends Node2D

@export var shootSpeed = 1.0
@export var bullets = 8

const BULLET = preload("res://scenes/bullet.tscn")

@onready var sprite_left: Sprite2D = $SpriteLeft
@onready var sprite_right: Sprite2D = $SpriteRight
@onready var marker_left: Marker2D = $MarkerLeft
@onready var marker_right: Marker2D = $MarkerRight
@onready var shoot_speed_timer = $shootSpeedTimer

var canShoot: bool = true
var bulletDirection: Vector2 = Vector2(1,0)
var isLeft: bool = false
var bullets_shot: int = 0

func _ready() -> void:
	shoot_speed_timer.wait_time = 1.0 / shootSpeed
	
	# Gun is not visible
	sprite_left.visible = false
	sprite_right.visible = false

func shoot():
	if canShoot:
		if bullets_shot >= bullets:
			return
			
		bullets_shot += 1
		print("Ammo: ", bullets - bullets_shot)
		canShoot = false
		shoot_speed_timer.start()
		
		var bulletNode = BULLET.instantiate()

		bulletNode.set_direction(bulletDirection)
		get_tree().root.add_child(bulletNode)
		if (isLeft):
			bulletNode.global_position = marker_left.global_position
		else:
			bulletNode.global_position = marker_right.global_position

func _on_shoot_speed_timer_timeout() -> void:
	canShoot = true

func setup_direction(direction):
	bulletDirection = direction
