extends Control

const WERKUDARA_STATS := preload("res://characters/Werkudara/werkudara.tres")
const ARJUNA_STATS := preload("res://characters/Arjuna/arjuna_stats.tres")
const NAKULA_STATS := preload("res://characters/Nakula/nakula_stats.tres")
const SADEWA_STATS := preload("res://characters/Sadewa/sadewa_stats.tres")
const YUDHISTIRA_STATS := preload("res://characters/Yudistira/yudhistira.tres")

@onready var title: Label = %Title
@onready var description: Label = %Description
@onready var character_portrait: TextureRect = %CharacterPortrait

var current_character: CharacterStats : set = set_current_character

func _on_start_pressed() -> void:
	set_current_character(WERKUDARA_STATS)

func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait = current_character.character

func _on_werkudara_pressed() -> void:
	pass


func _on_arjuna_pressed() -> void:
	pass # Replace with function body.


func _on_nakula_pressed() -> void:
	pass # Replace with function body.


func _on_sadewa_pressed() -> void:
	pass # Replace with function body.


func _on_yudhistira_pressed() -> void:
	pass # Replace with function body.
