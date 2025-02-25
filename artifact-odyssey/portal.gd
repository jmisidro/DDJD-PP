extends Area2D
class_name Portal

@export var target_portal: Portal

func _on_body_entered(body: Node2D) -> void:
	print(body)
	if (target_portal):
		body.position = target_portal.position
		
