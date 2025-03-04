extends Area2D
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	body.health = body.MAX_HEALTH
	print("Restored player max health")
	animation_player.play("pickHealth")
