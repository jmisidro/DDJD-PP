extends Node2D

@export var is_locked: bool = false
@export var cost: int = 5
@export var color: String = "blue"
@export var treasure: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_node("/root/Game/GameManager")
@onready var area_label: Label = $AreaLabel

signal chest_opened

var is_open: bool = false
var player_near: bool = false

func _ready() -> void:
	treasure.visible = false
	
	area_label.text = "Press E to open the chest! Cost: " + str(cost)
	area_label.visible = false
	
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
	
	# Update the player's moneya	
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
	print("You found a treasure!")
	if (treasure):
		pop_treasure()
		
func pop_treasure():
	treasure.visible = true
	var tween = get_tree().create_tween()  # Create a tween for animation
	tween.tween_property(treasure, "position", treasure.position + Vector2(0, -50), 0.5).set_trans(Tween.TRANS_BOUNCE)


func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		open()
		

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true
		area_label.visible = true  # Show text


func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false
		area_label.visible = false  # Show text
