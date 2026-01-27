class_name PauseLayer
extends CanvasLayer

signal save_and_quit

@onready var continue_button: Button = %ContinueButton
@onready var main_menu_button: Button = %MainMenuButton

func _ready() -> void:
	continue_button.pressed.connect(_unpause)
	main_menu_button.pressed.connect(_main_menu_button_pressed)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		if visible:
			_unpause()
		else:
			_pause()
			
		get_viewport().set_input_as_handled()
	
func _pause() -> void:
	show()
	get_tree().paused = true

func _unpause() -> void:
	hide()
	get_tree().paused = false

func _main_menu_button_pressed() -> void:
	get_tree().paused = false
	save_and_quit.emit()
