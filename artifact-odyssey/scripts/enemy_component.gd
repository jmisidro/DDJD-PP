extends Area2D
class_name EnemyComponent

@export var health_component: HealthComponent
@export var attack_damage := 5
@onready var player_hurt: AudioStreamPlayer2D = $"../PlayerHurt"


func damage(dmg: int):
	print("Enemy received damage: ", dmg)
	if (health_component):
		health_component.damage(dmg)

func _on_body_entered(body):
	if body.name == "Player":
		body.damage(attack_damage)
		player_hurt.play()
		print("damaged player for ", attack_damage)
