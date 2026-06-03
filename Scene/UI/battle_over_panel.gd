class_name BattleOverPanel
extends Panel

enum Type {WIN, LOSE}

@onready var label: Label = %Label
@onready var continue_button: Button = %ContinueButton
@onready var restart_button: Button = %RestartButton

const SAVE_FILE_PATH := "user://savegame.tres"

func _ready() -> void:
	hide()
	continue_button.pressed.connect(_on_continue_pressed)
	restart_button.pressed.connect(_on_restart_pressed)
	Events.battle_over_screen_requested.connect(show_screen)

func show_screen(text: String, type: Type) -> void:
	label.text = text
	continue_button.visible = type == Type.WIN
	restart_button.visible = type == Type.LOSE
	
	if type == Type.WIN and RunManager.current_floor >= 44:
		continue_button.text = "TAMAT - MENU UTAMA"
	else:
		continue_button.text = "LANJUT"
	show()

func _on_continue_pressed() -> void:
	if RunManager.current_floor >= 44 or continue_button.text.contains("TAMAT"):
		get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")
	else:
		Events.battle_won.emit()

func _on_restart_pressed() -> void:
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var err = DirAccess.remove_absolute(SAVE_FILE_PATH)
		if err != OK:
			printerr("Failed to delete save file. Error code: ", err)
	
	get_tree().paused = false
	
	get_tree().change_scene_to_file("res://Scene/UI/main_menu.tscn")
