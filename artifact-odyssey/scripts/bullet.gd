extends Area2D

@export var speed: int = 700
@export var damage: int = 10

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
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("enemy"):
		area.damage(damage)
	queue_free()
