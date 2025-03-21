extends Area2D

@export var speed: int = 700
@export var damage: int = 10
@onready var animation_player = $AnimationPlayer

var direction: Vector2

func _ready() -> void:
	await get_tree().create_timer(3).timeout 
	queue_free()

func set_direction(bulletDirection):
	direction = bulletDirection
	rotation = direction.angle()  # Correctly rotates the bullet

func _physics_process(delta):
	global_position += direction * speed * delta

	
func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		body.damage(damage)
		animation_player.play("shot_player_hurt")
	else:
		queue_free()
