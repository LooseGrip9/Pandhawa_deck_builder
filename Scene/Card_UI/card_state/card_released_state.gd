extends CardState

var played: bool

# CardPlayedState.gd

func enter() -> void:
	played = false
	
	if not card_ui.targets.is_empty():
		played = true
		card_ui.play() # This calls Card.play(), which now handles the Conch perfectly
		Events.tooltip_hide_requested.emit()

func on_input(event: InputEvent) -> void:
	if played:
		return
	transition_requested.emit(self, CardState.State.BASE)
