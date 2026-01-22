class_name Campfire
extends Control

@export var char_stats: CharacterStats

var button_type = null

func _on_rest_button_pressed() -> void:
	char_stats.heal(ceili(char_stats.max_health) * 0.3)
	button_type = "rest"
	$FadeTransition.show()
	$FadeTransition/Timer.start()
	$FadeTransition/AnimationPlayer.play("fade_in")

func _on_fade_timer_timeout() -> void:
	Events.campfire_exited.emit()
