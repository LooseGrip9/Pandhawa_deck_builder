extends CardState

const MOUSE_Y_SNAPBACK_THRESHOLD := 138

func enter() -> void:
	card_ui.targets.clear()
	
	var target_pos = card_ui.global_position
	
	target_pos.y -= 10
	card_ui.animate_to_position(target_pos, 0.2)
	var rot_tween = create_tween()
	rot_tween.tween_property(card_ui, "rotation", 0.0, 0.2)
	
	card_ui.drop_point_detector.monitoring = false
	
	Events.card_aim_started.emit(card_ui)
	
	card_ui.rotation = 0

func exit() -> void:
	Events.card_aim_ended.emit(card_ui)

func on_input(event: InputEvent) -> void:
	var mouse_motion := event is InputEventMouseMotion
	var mouse_at_botton := card_ui.get_global_mouse_position().y > MOUSE_Y_SNAPBACK_THRESHOLD
	
	if (mouse_motion and mouse_at_botton) or event.is_action_pressed("right_mouse"):
		transition_requested.emit(self, CardState.State.BASE)
	elif event.is_action_released("left_mouse") or event.is_action_pressed("left_mouse"):
		transition_requested.emit(self, CardState.State.RELEASED)
