extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 10
var health: float

func _ready() -> void:
	health = MAX_HEALTH

func damage(dmg: int):
	health -= dmg
	
	if health <= 0:
		get_parent().queue_free()
