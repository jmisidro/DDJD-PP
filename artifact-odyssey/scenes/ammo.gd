extends Area2D

@onready var animation_player = $AnimationPlayer

func _on_body_entered(body):
	if(body.has_gun):
		if(body.gun.bullets_shot != 0):
			body.gun.bullets_shot = 0
			
			#Update ammo text
			body.ammo_label.text=str(body.gun.bullets-body.gun.bullets_shot) +"/"+str(body.gun.bullets)
			
			#Animate the reload
			#body.gun.sprite_left.animation = "reload"
			#body.gun.sprite_right.animation = "reload"
			#body.gun.sprite_left.play()
			#body.gun.sprite_right.play()
			
			print("Restored ammo to 8")
			animation_player.play("ammo")
