class_name CharacterSelector
extends Control

const RUN_SCENE = preload("res://Scene/run/run.tscn")
const WERKUDARA_STATS := preload("res://characters/Werkudara/werkudara.tres")
const ARJUNA_STATS := preload("res://characters/Arjuna/arjuna_stats.tres")
const NAKULA_STATS := preload("res://characters/Nakula/nakula_stats.tres")
const SADEWA_STATS := preload("res://characters/Sadewa/sadewa_stats.tres")
const YUDHISTIRA_STATS := preload("res://characters/Yudistira/yudhistira.tres")

@export var run_startup: RunStartup

@onready var title: Label = $VBoxContainer/Title
@onready var description: Label = $VBoxContainer/Description
@onready var character_portrait: TextureRect = $CharacterPortrait

var button_type = null
var current_character: CharacterStats : set = set_current_character

func _ready() -> void:
	$ColorRect/AnimationPlayer.play("fade_out")
	set_current_character(WERKUDARA_STATS)
	
	description.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	description.add_theme_constant_override("line_spacing", 10)
	
	title.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _on_start_pressed() -> void:
	button_type = "start"
	
	RunManager.current_character = current_character
	
	run_startup.type = run_startup.Type.NEW_RUN
	run_startup.picked_character = current_character
	
	if has_node("ColorRect/AnimationPlayer"):
		$ColorRect.show()
		$ColorRect/AnimationPlayer.play("fade_in")
		await $ColorRect/AnimationPlayer.animation_finished

	get_tree().change_scene_to_file("res://Scene/cutscene/opening_wekudara.tscn")

func set_current_character(new_character: CharacterStats) -> void:
	current_character = new_character
	title.text = current_character.character_name
	description.text = current_character.description
	character_portrait.texture = current_character.portrait

func _on_werkudara_pressed() -> void:
	set_current_character(WERKUDARA_STATS)

func _on_arjuna_pressed() -> void:
	set_current_character(ARJUNA_STATS)

func _on_nakula_pressed() -> void:
	set_current_character(NAKULA_STATS)

func _on_sadewa_pressed() -> void:
	set_current_character(SADEWA_STATS)

func _on_yudhistira_pressed() -> void:
	set_current_character(YUDHISTIRA_STATS)

func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		var result = get_tree().change_scene_to_packed(RUN_SCENE)
		
		if result != OK:
			get_tree().change_scene_to_file("res://Scene/run/run.tscn")
