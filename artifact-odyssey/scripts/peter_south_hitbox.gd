extends Area2D

@onready var rigid_body_2d: RigidBody2D = $".."

func damage(dmg: int):
	rigid_body_2d.damage(dmg)
