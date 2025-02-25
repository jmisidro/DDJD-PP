extends Area2D

@onready var timer = $Timer
@export var damage := 5

func _on_body_entered(body):
	if body.name == "Player":
		body.damage(damage)
		print("damaged player for ", damage)
