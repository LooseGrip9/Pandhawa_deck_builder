extends CardState


func  enter() -> void:
	card_ui.color.color = Color.DARK_GOLDENROD
	card_ui.state.text ="CLICKED"
	card_ui.drop_point_detector.monitoring = true

func on_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		transition_requested.emit(self, CardState.State.DRAGGING)
