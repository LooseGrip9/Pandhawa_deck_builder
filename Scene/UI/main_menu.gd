extends Node2D

var button_type = null
const CHAR_SELECTOR_SCENE := preload("res://Scene/UI/character_selector.tscn")
const RUN_SCENE := preload("res://Scene/run/run.tscn")

@export var run_startup: RunStartup
@onready var continue_button: Button = %Continue

func _ready() -> void:
	get_tree().paused = false
	continue_button.disabled = SaveGame.load_data() == null
	
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
	run_startup.type = RunStartup.Type.CONTINUED_RUN
	get_tree().change_scene_to_packed(RUN_SCENE)
