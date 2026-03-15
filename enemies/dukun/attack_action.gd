class_name DukunHexAction
extends EnemyAction

# Preload your curse card here! Make sure this path exactly matches your Godot file structure.
const CURSE = preload("res://common_cards/curse.tres") 

@export var damage := 8
@export var curse_amount := 2

func perform_action() -> void:
	if not enemy or not target:
		return
	
	var player := target as Player
	if not player:
		return
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	
	var damage_effect := DamageEffect.new()
	var target_array: Array[Node] = [target]
	var modified_dmg := enemy.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_DEALT)
	
	damage_effect.amount = modified_dmg
	damage_effect.sound = sound
	
	# --- STAGE 1: THE DARK CHANT (Floating up) ---
	tween.tween_property(enemy, "global_position:y", start.y - 30, 0.4)
	if enemy.sprite_2d:
		tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color(0.6, 0.1, 0.8), 0.4)
		if Shaker:
			tween.parallel().tween_callback(Shaker.shake.bind(enemy, 3, 0.4))
	
	# --- STAGE 2: DAMAGE & CURSE INJECTION ---
	tween.tween_callback(damage_effect.execute.bind(target_array))
	
	# Loop to add the correct amount of Curses directly to the player's draw pile
	tween.tween_callback(
		func():
			for i in range(curse_amount):
				player.stats.draw_pile.add_card(CURSE.duplicate())
	)
	
	# --- STAGE 3: RECOVERY ---
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	if enemy.sprite_2d:
		tween.parallel().tween_property(enemy.sprite_2d, "modulate", Color.WHITE, 0.4)
	
	tween.finished.connect(
		func():
			Events.enemy_action_completed.emit(enemy)
	)
	
	if sound:
		SFXPlayer.play(sound)

func update_intent_text() -> void:
	var player := target as Player
	if not player:
		return
		
	var modified_dmg := player.modifier_handler.get_modified_value(damage, Modifier.Type.DMG_TAKEN)
	var final_dmg := enemy.modifier_handler.get_modified_value(modified_dmg, Modifier.Type.DMG_DEALT)
	
	intent.current_text = intent.base_text % [final_dmg, curse_amount]
