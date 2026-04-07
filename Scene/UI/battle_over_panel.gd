class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton

func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(func(): get_tree().change_scene_to_file("res://Scene/UI/main.tscn"))
	Events.battle_over_screen_requested.connect(show_screen)

func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	restart_button.visible = type == Type.LOSE
	
	# Determine if it's the end of the game
	if type == Type.WIN and RunManager.current_floor >= 44:
		continue_button.text = "TAMAT - MENU UTAMA"
	else:
		continue_button.text = "LANJUT"
	show()

func _on_continue_pressed() -> void:
	if RunManager.current_floor >= 44 or continue_button.text.contains("TAMAT"):
		get_tree().change_scene_to_file("res://Scene/UI/main.tscn")
	else:
		Events.battle_won.emit()
