extends Area2D

@onready var game_manager = %GameManager
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ability_label: Label = $AbilityLabel
@onready var minix: Area2D = $"."
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

func _on_body_entered(body):
	if body.name == "Player":
		body.grant_godmode()
		animation_player.play("pickArtifact")

		# Show the label
		ability_label.visible = true

		# Hide it after 5 seconds
		await get_tree().create_timer(5.0).timeout
		ability_label.visible = false
		
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	minix.scale = Vector2(0, 0)
	collision_shape_2d.disabled = true
	ability_label.visible = false


func pop_treasure():		
	var tween = get_tree().create_tween()  # Create a tween for animation
	tween.set_parallel()  # Ensure both animations happen at the same time
	# Scale from 0 to 1 (makes it grow)
	tween.tween_property(minix, "scale", Vector2(4, 4), 0.5).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(minix, "position", minix.position + Vector2(0, -50), 0.5).set_trans(Tween.TRANS_BOUNCE)
	
	await get_tree().create_timer(0.5).timeout
	collision_shape_2d.disabled = false # Enable collision
