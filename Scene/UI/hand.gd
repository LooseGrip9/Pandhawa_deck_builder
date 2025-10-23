class_name Hand
extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in get_children():
		var card_ui := child as CardUI
		card_ui.parent = self
		card_ui.reparent_requested.connect(_on_card_ui_reparent_requested)
		

func _on_card_ui_reparent_requested(child: CardUI) -> void:
	child.reparent(self)
