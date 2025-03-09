extends Area2D
@onready var game_over: AudioStreamPlayer2D = $gameOver

@onready var timer = $Timer
@onready var game_manager: Node = get_node("/root/Game/GameManager")

func _on_body_entered(body):
	print("You died. :(")
	timer.start()
	game_over.play()


func _on_timer_timeout():
	game_manager.end_game()
