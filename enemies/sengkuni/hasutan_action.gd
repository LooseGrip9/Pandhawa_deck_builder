class_name ActionHasutan
extends EnemyAction

@export var base_damage: int = 5
@export var damage_per_card: int = 2

# We store the "Captured" damage here so it doesn't reset when hand is discarded
var captured_damage: int = 0

func _ready() -> void:
	# Snapshot the hand the moment the player ends their turn
	Events.player_turn_ended.connect(_on_player_turn_ended)

func _on_player_turn_ended() -> void:
	# Calculate and lock in the damage BEFORE the discard animation starts
	captured_damage = get_raw_damage()
	print("Sengkuni locked in Hasutan damage: ", captured_damage)

func get_raw_damage() -> int:
	var cards_in_hand := 0
	if enemy and enemy.is_inside_tree():
		var all_cards = enemy.get_tree().get_nodes_in_group("cards_in_hand")
		
		for card in all_cards:
			if not card.is_queued_for_deletion():
				cards_in_hand += 1
				
	return base_damage + (cards_in_hand * damage_per_card)

func update_intent_text() -> void:
	if enemy.current_action != self:
		return
	var player = target as Player
	if not player: return
	
	var raw: int = captured_damage if captured_damage > 0 else get_raw_damage()
	
	var modified_dmg: int = raw
	
	if enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	if player.modifier_handler:
		modified_dmg = player.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
	
	intent.current_text = intent.base_text % modified_dmg

func perform_action() -> void:
	if not enemy or not target: return
	
	var sprite := enemy.sprite_2d
	var start_pos := enemy.global_position
	var end_pos := target.global_position
	var original_scale := sprite.scale
	
	# Use the damage we locked in at the end of the player's turn
	var final_dmg := captured_damage if captured_damage > 0 else get_raw_damage()
	
	if enemy.modifier_handler:
		final_dmg = enemy.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_DEALT)
	if target is Player and target.modifier_handler:
		final_dmg = target.modifier_handler.get_modified_value(final_dmg, Modifier.Type.DMG_TAKEN)
	
	var main_tween := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	
	for i in range(3):
		var progress := (i + 1) / 3.0
		var segment_pos := start_pos.lerp(end_pos, progress)
		var y_offset := -60 if i % 2 == 0 else 60
		if i == 2: y_offset = 0 
		
		main_tween.tween_property(enemy, "global_position", segment_pos + Vector2(0, y_offset), 0.12)
		main_tween.parallel().tween_property(sprite, "scale", original_scale * (1.0 + (progress * 0.4)), 0.12)

	main_tween.tween_callback(func():
		Shaker.shake(enemy, 40.0, 0.4) 
		Shaker.shake(target, 30.0, 0.5)
		target.take_damage(final_dmg, Modifier.Type.NO_MODIFIER)
		
		captured_damage = 0
		
		var flash := create_tween()
		flash.tween_property(sprite, "modulate", Color.RED, 0.05)
		flash.tween_property(sprite, "modulate", Color.WHITE, 0.1)
	)
	
	main_tween.tween_interval(0.2)
	main_tween.tween_property(enemy, "global_position", start_pos, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	main_tween.parallel().tween_property(sprite, "scale", original_scale, 0.3)
	
	main_tween.finished.connect(func():
		Events.enemy_action_completed.emit(enemy)
	)
