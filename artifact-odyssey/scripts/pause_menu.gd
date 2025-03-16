extends Control

@onready var game_manager: Node = get_node("/root/Game/GameManager")
@onready var time_label: Label = $TimeLabel
@onready var artifacts_label: Label = $ArtifactsLabel

func format_time(seconds: int) -> String:
	var minutes = seconds / 60
	var remaining_seconds = seconds % 60
	return str(minutes) + " min " + str(remaining_seconds) + " sec "

func pause():
	game_manager.pause_game()
	
	# Display the game time when the end menu is shown
	var time = "%.2f" % Global.game_time
	time_label.text = "Time: " + format_time(int(time))
	artifacts_label.text = "Artifacts: " + str(Global.artifacts)
	
	get_tree().paused = true
	show()

func resume():
	get_tree().paused = false
	hide()
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:	
	hide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_button_pressed() -> void:
	resume()


func _on_restart_button_pressed() -> void:
	resume()
	get_tree().reload_current_scene()


func _on_quit_button_pressed() -> void:
	get_tree().quit()
