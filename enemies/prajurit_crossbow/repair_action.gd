class_name RepairAction
extends EnemyAction

@export var block_amount := 5

func perform_action() -> void:
	if not enemy:
		return
		
	enemy.stats.block += block_amount
	
	var jam = enemy.status_handler.get_status("macet")
	
	if jam:
		enemy.status_handler.remove_status("macet")
		
	var tween := create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(enemy, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(enemy, "scale", Vector2.ONE, 0.2)
	
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
