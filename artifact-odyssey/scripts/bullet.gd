extends Area2D

@export var speed: int = 700
@export var damage: int = 5

var direction: Vector2

func _ready() -> void:
	await get_tree().create_timer(3).timeout 
	queue_free()

func set_direction(bulletDirection):
	direction = bulletDirection
	rotation_degrees = rad_to_deg(global_position.angle_to_point(global_position + direction))

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	print(body)
	queue_free()
	if body.is_in_group("enemy"):
		print("hit enemy")
