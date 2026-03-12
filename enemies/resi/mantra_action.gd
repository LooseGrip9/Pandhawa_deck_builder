class_name ResiMantraAction
extends EnemyAction

@export var damage := 6
@export var sabotage_amount := 1
@export var sabotage_status_res: Status

func perform_action() -> void:
	if not enemy or not target:
		return
	
	if not enemy.is_connected("tree_exiting", _on_resi_defeated):
		enemy.tree_exiting.connect(_on_resi_defeated.bind(target))
	
	var tween := create_tween().set_trans(Tween.TRANS_SINE)
	var start_pos := enemy.global_position
	
	tween.tween_property(enemy, "global_position:y", start_pos.y - 20, 0.4)
	
	tween.tween_callback(
		func():
			var damage_effect := DamageEffect.new()
			damage_effect.amount = enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
			damage_effect.execute([target])
			
			var handler = target.get("status_handler")
			if not handler:
				handler = target.get_node_or_null("StatusHandler")
			if not handler:
				handler = target.get_node_or_null("status_handler")
				
			if not handler or not sabotage_status_res:
				return

			var current_sab = handler.get_status("sabotase")
			if not current_sab:
				var new_sab = sabotage_status_res.duplicate()
				new_sab.stacks = sabotage_amount
				handler.add_status(new_sab)
			else:
				current_sab.stacks += sabotage_amount
			
			handler.statuses_changed.emit()
	)
	
	tween.tween_interval(0.3)
	tween.tween_property(enemy, "global_position:y", start_pos.y, 0.4)
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))

func _on_resi_defeated(player_node: Node2D) -> void:
	if is_instance_valid(player_node):
		var handler = player_node.get("status_handler")
		if not handler:
			handler = player_node.get_node_or_null("StatusHandler")
		if not handler:
			handler = player_node.get_node_or_null("status_handler")
			
		if handler:
			handler.remove_status("sabotase")
			handler.statuses_changed.emit()
