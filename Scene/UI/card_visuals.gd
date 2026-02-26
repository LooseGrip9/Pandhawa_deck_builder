class_name CardVisuals
extends Control

@export var card: Card : set = set_card

@onready var panel: Panel = $CanvasGroup/Panel
@onready var cost: Label = $DataContainer/Cost
@onready var icon: TextureRect = $DataContainer/Icon

func set_card(value: Card) -> void:
	if not is_node_ready():
		await ready
	
	card = value
	cost.text = str(card.cost)
	icon.texture = card.icon
	
	var style_names := ["panel", "normal", "hover", "pressed", "focus", "disabled"]
	
	for style in style_names:
		if panel.has_theme_stylebox(style):
			var stylebox: StyleBoxFlat = panel.get_theme_stylebox(style).duplicate()
			stylebox.bg_color = card.RARITY_COLORS[card.rarity]
			
			if style == "hover":
				stylebox.bg_color = stylebox.bg_color.lightened(0.1)
			
			panel.add_theme_stylebox_override(style, stylebox)

# CardVisuals.gd

func update_cost(new_cost: int, is_free: bool) -> void:
	cost.text = str(new_cost)
	
	if is_free:
		cost.add_theme_color_override("font_color", Color.GREEN)
	else:
		cost.remove_theme_color_override("font_color")
