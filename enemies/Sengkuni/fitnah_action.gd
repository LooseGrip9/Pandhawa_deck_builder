class_name FitnahAction
extends EnemyAction

@export var fitnah_card: Card
@export var amount := 2

func perform_action() -> void:
	if not enemy or not target or not fitnah_card:
		return
	
	# Force hide the intent at the absolute start of the animation
	if enemy.intent_ui:
		enemy.intent_ui.hide()
	
	# Start the shaking animation
	var tween := create_tween().set_loops(4)
	tween.tween_property(enemy, "position:x", enemy.position.x + 5, 0.05)
	tween.tween_property(enemy, "position:x", enemy.position.x - 5, 0.05)
	
	tween.finished.connect(
		func():
			for i in range(amount):
				Events.card_added_to_deck.emit(fitnah_card)
			
			print("Sengkuni adds ", amount, " Fitnah cards to your deck!")
			
			Events.enemy_action_completed.emit(enemy)
	)
