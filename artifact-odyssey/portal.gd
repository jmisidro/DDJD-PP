extends Area2D
class_name Portal

@export var target_portal: Portal
@onready var game_manager = %GameManager

func _on_body_entered(body: Node2D) -> void:
	if (target_portal  && !game_manager.traveling_portal):
		body.position = target_portal.position
		game_manager.traveling_portal = true


func _on_body_exited(body):
	game_manager.traveling_portal = false
