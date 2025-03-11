extends Area2D
@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	if(body.health != body.MAX_HEALTH):
		body.health = body.MAX_HEALTH
		print("Restored player max health")
		animation_player.play("pickHealth")
