extends Area2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ability_label: Label = $AbilityLabel

func _ready() -> void:
	ability_label.visible = false

func _on_body_entered(body):
	body.grant_flight_ability()
	animation_player.play("pickArtifact")

	# Show the label
	ability_label.visible = true

	# Hide it after 10 seconds
	await get_tree().create_timer(10.0).timeout
	ability_label.visible = false
