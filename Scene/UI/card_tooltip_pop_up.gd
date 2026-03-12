class_name CardTooltipPopup
extends Control

const CARD_MENU_UI_SCENE = preload("res://Scene/UI/card_menu_ui.tscn")

@export var background_color: Color = Color("000000b0") # Fixed hex string format

@onready var background: ColorRect = $Background
@onready var tooltip_card: CenterContainer = %TooltipCard
@onready var card_description: RichTextLabel = %Description
@onready var flavour_etxt: RichTextLabel = %Description2

func _ready() -> void:
	_clear_tooltip_card()
	background.color = background_color

func _on_gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_mouse"):
		hide_tooltip()

func show_tooltip(card: Card) -> void:
	_clear_tooltip_card()
	
	var new_card := CARD_MENU_UI_SCENE.instantiate() as CardMenuUI
	tooltip_card.add_child(new_card)
	new_card.card = card
	new_card.tooltip_requested.connect(hide_tooltip.unbind(1))
	
	card_description.text = card.get_default_tooltip()
	
	if flavour_etxt:
		flavour_etxt.text = card.flavour_text
		flavour_etxt.visible = not card.flavour_text.is_empty()
	
	show()

func hide_tooltip() -> void:
	if not visible:
		return
	hide()

func _clear_tooltip_card() -> void:
	for child in tooltip_card.get_children():
		child.queue_free()
