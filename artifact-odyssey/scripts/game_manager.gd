extends Node

@export var NUM_ARTIFACTS: int = 10
@onready var game_timer: Timer = $"../GameTimer"
@onready var money_label = $"../Player/Camera2D/moneyLabel"
@onready var money_2d = $"../Player/Camera2D/money2D"
@onready var health_label = $"../Player/Camera2D/healthLabel"
@onready var health_2d = $"../Player/Camera2D/health2D"
@onready var player = $"../Player"

var money = 0
var sprite_width = 80
var artifacts = 0
var traveling_portal  = false

func add_artifact():
	artifacts += 1
	print("Collected an Artifact! Total: ", artifacts)

func add_money(qty):
	money += qty
	money_label.text = str(money) + "X"
	
func remove_money(qty):
	money -= qty
	money_label.text = str(money) + "X"
	
func won():
	Global.won = true

func end_game():
	# Stop the timer
	Global.game_time = game_timer.elapsed_time
	game_timer.stop()
	Global.artifacts = artifacts
	
	# Transition to the end game menu
	get_tree().change_scene_to_file("res://scenes/end_menu.tscn")

func _on_camera_2d_draw():
	var viewport_size = get_viewport().size
	var screen_x = viewport_size.x/2
	var screen_y = viewport_size.y/2
	
	health_label.position = Vector2(screen_x - health_label.size.x - sprite_width, health_label.size.y/2 - screen_y - 10)
	health_2d.position = Vector2(screen_x - sprite_width/2, health_label.size.y - screen_y - 15)
	
	money_label.position = Vector2(screen_x - money_label.size.x - sprite_width, money_label.size.y/2 - screen_y + health_label.size.y*1.15 - 10)
	money_2d.position = Vector2(screen_x - sprite_width/2, money_label.size.y  - screen_y + health_label.size.y*1.15 - 15)

func _process(delta):
	health_label.text = str(player.health) + "/20"
	if (player.health > 10):
		health_2d.speed_scale = 1.0
	if (player.health <= 10 && player.health > 5):
		health_2d.speed_scale =  2.0
	if (player.health <= 5):
		health_2d.speed_scale =  4.0
		
	# End Game
	if artifacts >= NUM_ARTIFACTS:
		won()
		end_game()
