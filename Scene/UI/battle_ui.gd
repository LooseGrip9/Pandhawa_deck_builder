class_name BattleUI
extends CanvasLayer

@export var char_stats: CharacterStats : set = _set_char_stats

@onready var hand: Hand = $Hand as Hand
@onready var mana_ui : ManaUI = $ManaUI as ManaUI
@onready var end_turn_button: Button = %EndTurnButton

func _ready() -> void:
	Events.player_hand_drawn.connect(on_player_hand_drawn)
	end_turn_button.pressed.connect(on_end_turn_button_pressed)

func _set_char_stats(value: CharacterStats) -> void:
	char_stats = value
	mana_ui.char_stats = char_stats
	hand.char_stats = char_stats

func on_player_hand_drawn() -> void:
	end_turn_button.disabled = false

func on_end_turn_button_pressed() -> void:
	end_turn_button.disabled = true
	Events.player_turn_ended.emit()
