class_name DukunSantetAction
extends EnemyAction

@export var inherent_block := 6
@export var santet_status_res: Status

func update_intent_text() -> void:
	if not intent or not enemy:
		return
	intent.current_text = intent.base_text

func perform_action() -> void:
	if not enemy:
		Events.enemy_action_completed.emit(enemy)
		return

	var tween := create_tween()
	var original_pos := enemy.global_position

	# --- STAGE 1: ENTERING THE TRANCE ---
	tween.tween_property(enemy, "global_position:y", original_pos.y - 10, 0.2)
	if enemy.sprite_2d:
		# Dark blood-red pulse
		tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color(0.8, 0.1, 0.2), 0.3) 

	# --- STAGE 2: APPLY BLOCK AND SANTET ---
	tween.tween_callback(
		func():
			# Gain block
			var block_effect := BlockEffect.new()
			block_effect.amount = inherent_block
			if sound:
				block_effect.sound = sound
			block_effect.execute([enemy])
			if enemy.has_method("update_stats"):
				enemy.update_stats()

			if santet_status_res and enemy.status_handler:
				var current_santet = enemy.status_handler.get_status("santet")
				if not current_santet:
					var new_santet = santet_status_res.duplicate()
					new_santet.stacks = 1
					enemy.status_handler.add_status(new_santet)
				else:
					current_santet.stacks += 1
					
				enemy.status_handler.statuses_changed.emit()

			if Shaker:
				Shaker.shake(enemy, 3, 0.2)
	)

	tween.tween_interval(0.2)
	tween.tween_property(enemy, "global_position", original_pos, 0.3)
	if enemy.sprite_2d:
		tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.3)

	tween.finished.connect(func():
		enemy.update_intent()
		Events.enemy_action_completed.emit(enemy)
	)
