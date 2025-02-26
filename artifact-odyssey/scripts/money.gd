extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	game_manager.add_money(1)
	animation_player.play("pickUpMoney")
