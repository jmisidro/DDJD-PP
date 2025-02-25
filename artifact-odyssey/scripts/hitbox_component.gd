extends Area2D
class_name HitboxComponent

@export var health_component: HealthComponent

func damage(dmg: int):
	if (health_component):
		health_component.damage(dmg)
