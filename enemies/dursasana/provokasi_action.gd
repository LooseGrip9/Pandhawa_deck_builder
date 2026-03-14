class_name ActionProvokasi
extends EnemyAction

@export var provokasi_status: Status

func perform_action() -> void:
	if not enemy or not target: return

	var sprite := enemy.sprite_2d
	var original_scale := sprite.scale
	
	var tween := create_tween().set_trans(Tween.TRANS_SPRING).set_ease(Tween.EASE_OUT)
	
	tween.tween_property(sprite, "scale", original_scale * 1.3, 0.2)
	tween.tween_property(sprite, "modulate", Color.RED, 0.2)
	
	tween.tween_callback(func():
		Shaker.shake(enemy, 15.0, 0.3)
		var handler = target.get_node_or_null("StatusHandler")
		if handler and handler.has_method("add_status") and provokasi_status:
			var new_taunt = provokasi_status.duplicate() as Status
			handler.add_status(new_taunt)
			print("Dursasana applied Provokasi!")
	)
	
	tween.tween_interval(0.5)
	tween.tween_property(sprite, "scale", original_scale, 0.2)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	tween.finished.connect(func(): Events.enemy_action_completed.emit(enemy))
