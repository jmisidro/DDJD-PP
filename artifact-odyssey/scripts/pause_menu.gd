extends Control

func pause():
	get_tree().paused = true
	show()

func resume():
	get_tree().paused = false
	hide()
	

func	 _ready() -> void:
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
