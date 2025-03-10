extends Control

@onready var game_over_label: Label = $"Game Over"
@onready var winner_label: Label = $Winner
@onready var time_label: Label = $TimeLabel
@onready var artifacts_label: Label = $ArtifactsLabel
@onready var game_over_sound = $gameOverSound

	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	# Display the game time when the end menu is shown
	var time = "%.2f" % Global.game_time
	time_label.text = "Time: " + time + " seconds"
	artifacts_label.text = "Artifacts: " + str(Global.artifacts)
	
	if Global.won:
		winner_label.visible = true
	else:
		game_over_label.visible = true
		game_over_sound.play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main.tscn")


func _on_quit_button_pressed() -> void:
	get_tree().quit()
