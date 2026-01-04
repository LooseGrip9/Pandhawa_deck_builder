class_name CardMenuUI
extends CenterContainer

signal tooltip_requested(card: Card)

const BASE_STYLEBOX := preload("res://Scene/Card_UI/card_base_style_box.tres")
const HOVER_STYLEBOX := preload("res://Scene/Card_UI/card_base_hover.tres")

@export var card: Card : set = set_card

@onready var visuals: CardVisuals = $Visuals

func _on_visuals_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		tooltip_requested.emit(card)

func _on_visuals_mouse_entered() -> void:
	var stylebox: StyleBoxFlat = HOVER_STYLEBOX.duplicate()
	stylebox.bg_color = card.RARITY_COLORS[card.rarity].lightened(0.1)
	visuals.panel.add_theme_stylebox_override("panel", stylebox)

func _on_visuals_mouse_exited() -> void:
	var stylebox: StyleBoxFlat = BASE_STYLEBOX.duplicate()
	stylebox.bg_color = card.RARITY_COLORS[card.rarity]
	visuals.panel.add_theme_stylebox_override("panel", stylebox)

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	visuals.card = card
