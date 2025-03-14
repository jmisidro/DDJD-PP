extends Node2D

@export var treasure: Node2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var game_manager: Node = get_node("/root/Game/GameManager")
@onready var area_label: Label = $AreaLabel
@onready var animation_player = $AnimationPlayer

signal chest_opened

var is_open: bool = false
var player_near: bool = false
var treasure_collision : CollisionShape2D

func _ready() -> void:
	# Start treasure at 0 scale (invisible) 
	if treasure:
		treasure.scale = Vector2(0, 0)
		treasure_collision = treasure.get_node_or_null("CollisionShape2D")

		if treasure_collision:
			treasure_collision.disabled = true
		else:
			print("Error: CollisionShape2D not found in treasure!")
	
	area_label.visible = false

func open():
	if is_open:
		return
	
	# Change animation	
	animated_sprite_2d.animation = "special"
	animated_sprite_2d.play()
		
	is_open = true
	emit_signal("chest_opened")
	print("You found AAS!")
	
	if treasure:
		pop_treasure()
		
func pop_treasure():		
	var tween = get_tree().create_tween()  # Create a tween for animation
	tween.set_parallel()  # Ensure both animations happen at the same time
	# Scale from 0 to 1 (makes it grow)
	tween.tween_property(treasure, "scale", Vector2(4, 4), 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(treasure, "position", treasure.position + Vector2(0, -50), 0.5).set_trans(Tween.TRANS_BOUNCE)
	
	await get_tree().create_timer(0.5).timeout
	treasure_collision.disabled = false # Enable collision


func _process(delta):
	if player_near and Input.is_action_just_pressed("interact"):
		open()
		
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_near = true
		if !is_open:
			area_label.visible = true  

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Player":
		player_near = false
		area_label.visible = false  
