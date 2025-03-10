extends Area2D

@onready var game_manager: Node = get_node("/root/Game/GameManager")

func _on_body_entered(body):
	print("You died. :(")
	game_manager.end_game()
