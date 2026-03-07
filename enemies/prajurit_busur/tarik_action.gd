class_name NockAction
extends EnemyAction

@export var draw_amount := 2
@export var status_to_apply: Status

func update_intent_text() -> void:
	if not intent:
		return
	
	if "%s" in intent.base_text:
		intent.current_text = intent.base_text % draw_amount
	else:
		intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy:
		push_error("BOW ENEMY ERROR: NockAction doesn't know who the enemy is!")
		return
		
	if not status_to_apply:
		push_error("BOW ENEMY ERROR: NockAction is missing the 'tarik_busur' resource in the Inspector!")
		Events.enemy_action_completed.emit(enemy)
		return
		
	var new_status = status_to_apply.duplicate()
	new_status.stacks = draw_amount
	enemy.status_handler.add_status(new_status)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start_y := enemy.global_position.y
	
	tween.tween_property(enemy, "global_position:y", start_y - 15, 0.2)
	tween.tween_property(enemy, "global_position:y", start_y, 0.2)
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
