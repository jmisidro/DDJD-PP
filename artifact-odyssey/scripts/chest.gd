extends Node2D

@export var is_locked: bool = false
@export var cost: int = 5
@export var has_treasure: bool = true
@export var color: String = "blue"
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_node("/root/Game/GameManager")

signal chest_opened

var is_open: bool = false
var player_near: bool = false

func _ready() -> void:
	if color == "red":
		animated_sprite_2d.animation = "red"
	elif color == "green":
		animated_sprite_2d.animation = "green"
	else:
		animated_sprite_2d.animation = "blue"

func open():
	if is_open:
		return
		
	if is_locked:
		print("The chest is locked!")
		return
		
	if game_manager.money < cost:
		print("Not enough money!")
		return
	
	# Update the player's money	
	game_manager.remove_money(cost)
	
	if animated_sprite_2d.animation == "blue":
		animated_sprite_2d.animation = "blue_open"
	elif animated_sprite_2d.animation == "green":
		animated_sprite_2d.animation = "green_open"
	else:
		animated_sprite_2d.animation = "red_open"
		
	animated_sprite_2d.play()
		
	is_open = true
	emit_signal("chest_opened")
	if has_treasure:
		print("You found a treasure!")

func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		open()
		

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false
