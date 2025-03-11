extends Area2D

@onready var player_hurt = $"../PlayerHurt"
var damage = 10

func _on_body_entered(body):
	if body.name == "Player":
		body.damage(damage)
		player_hurt.play()
		print("damaged player for ", damage)
