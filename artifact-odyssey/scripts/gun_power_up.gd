extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _on_body_entered(body):
	body.grant_gun_ability()
	animation_player.play("pickArtifact")
