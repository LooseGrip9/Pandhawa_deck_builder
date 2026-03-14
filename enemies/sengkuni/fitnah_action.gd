class_name ActionFitnah
extends EnemyAction

@export var fitnah_card: Card 
@export var amount: int = 1

func perform_action() -> void:
	if not enemy or not target: 
		return
	
	var sprite = enemy.sprite_2d
	var original_scale = sprite.scale
	var zoom_scale = original_scale * 1.5
	
	var tween = create_tween().set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(sprite, "scale", zoom_scale, 0.4)
	
	tween.tween_callback(func():
		Shaker.shake(enemy, 30.0, 0.5) 
		
		var flash = create_tween()
		flash.tween_property(sprite, "modulate", Color.PURPLE, 0.1)
		flash.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	)
	
	tween.tween_interval(0.2)
	tween.tween_callback(func():
		for i in range(amount):
			Events.card_added_to_deck.emit(fitnah_card)
	)
	
	tween.tween_interval(0.3)
	tween.tween_property(sprite, "scale", original_scale, 0.4)
	
	tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
