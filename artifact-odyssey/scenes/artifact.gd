@tool
extends Area2D

@onready var game_manager: Node = get_node("/root/Game/GameManager")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var artifact_texture: Texture:
	set(value):
		artifact_texture = value
		update_texture()

		


func _ready():
	update_texture()

func update_texture():
	if $Sprite2D:
		$Sprite2D.texture = artifact_texture

func _on_body_entered(body):
	game_manager.add_artifact()
	animation_player.play("pickArtifact")
