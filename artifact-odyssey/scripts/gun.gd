extends Node2D

@export var shootSpeed = 1.0
@export var bullets = 8
@export var reloadTime = 1.0

const BULLET = preload("res://scenes/bullet.tscn")

@onready var sprite_left: AnimatedSprite2D = $SpriteLeft
@onready var sprite_right: AnimatedSprite2D = $SpriteRight
@onready var marker_left: Marker2D = $MarkerLeft
@onready var marker_right: Marker2D = $MarkerRight
@onready var shoot_speed_timer = $shootSpeedTimer
@onready var gun_shot_audio = $GunShotAudio

var canShoot: bool = true
var bulletDirection: Vector2 = Vector2(1,0)
var isLeft: bool = false
var bullets_shot: int = 0
var isReloading: bool = false
var reload_timer: Timer

func _ready() -> void:
	shoot_speed_timer.wait_time = 1.0 / shootSpeed
	
	# Gun is not visible
	sprite_left.visible = false
	sprite_right.visible = false
	
	# Initialize Jump Buffer Timer
	reload_timer = Timer.new()
	reload_timer.wait_time = reloadTime
	reload_timer.one_shot = true
	reload_timer.timeout.connect(_clear_reload_timer)
	add_child(reload_timer)
	
func _clear_reload_timer():
	isReloading = false

func shoot():
	if canShoot and !isReloading:
		if bullets_shot >= bullets:
			return
			
		bullets_shot += 1
		print("Ammo: ", bullets - bullets_shot)
		canShoot = false
		sprite_left.animation = "fire"
		sprite_right.animation = "fire"
		sprite_left.play()
		sprite_right.play()
		shoot_speed_timer.start()
		gun_shot_audio.play()
		
		var bulletNode = BULLET.instantiate()

		bulletNode.set_direction(bulletDirection)
		get_tree().root.add_child(bulletNode)
		if (isLeft):
			bulletNode.global_position = marker_left.global_position
		else:
			bulletNode.global_position = marker_right.global_position

func reload():
	isReloading = true
	sprite_left.animation = "reload"
	sprite_right.animation = "reload"
	sprite_left.play()
	sprite_right.play()
	reload_timer.start()

func _on_shoot_speed_timer_timeout() -> void:
	sprite_left.animation = "default"
	sprite_right.animation = "default"
	canShoot = true

func setup_direction(direction):
	bulletDirection = direction
