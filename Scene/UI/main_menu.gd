extends Node2D

var button_type = null


func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_start_pressed() -> void:
	button_type = "start"
	$ColorRect.show()
	$ColorRect/Timer.start()
	$ColorRect/AnimationPlayer.play("fade_in")

func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://Scene/UI/character_selector.tscn")


func _on_continue_pressed() -> void:
	print("Continue Run")
