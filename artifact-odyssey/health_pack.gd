extends Area2D

func _on_body_entered(body):
	body.health = body.MAX_HEALTH
	print("Restored player max health")
	queue_free()
