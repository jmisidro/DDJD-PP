extends Area2D

@onready var timer = $Timer
@onready var game_manager: Node = %GameManager

func _on_body_entered(body):
	print("You died. :(")
	timer.start()


func _on_timer_timeout():
	game_manager.end_game()
