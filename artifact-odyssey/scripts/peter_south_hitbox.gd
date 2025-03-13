extends Area2D

@onready var character_body_2d: CharacterBody2D = $".."

func damage(dmg: int):
	character_body_2d.damage(dmg)
