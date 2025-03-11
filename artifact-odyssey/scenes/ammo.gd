extends Area2D

@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	if(body.has_gun):
		if(body.gun.bullets_shot != 0):
			body.gun.bullets_shot = 0
			print("Restored ammo to 8")
