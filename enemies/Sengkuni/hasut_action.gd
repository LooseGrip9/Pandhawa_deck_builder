class_name HasutanAction
extends EnemyAction

@export var base_damage := 5
@export var scaling_per_card := 1.5

var recorded_hand_size := 0
var is_locked_for_attack := false

func _ready() -> void:
	Events.player_turn_ended.connect(_on_player_turn_ended)

func _on_player_turn_ended() -> void:
	# THE FIX: Only record the hand size if Sengkuni is actually planning to use Hasutan!
	if enemy and enemy.current_action == self:
		var cards = get_tree().get_nodes_in_group("cards_in_hand")
		recorded_hand_size = cards.size()
		is_locked_for_attack = true
		update_intent_text()

func update_intent_text() -> void:
	var total_damage: int
	
	if is_locked_for_attack:
		# Use the locked snapshot ONLY during Sengkuni's attack phase
		total_damage = base_damage + round(recorded_hand_size * scaling_per_card)
	else:
		# Otherwise, use the live hand size (which will be 0 right after his turn ends)
		var live_cards = get_tree().get_nodes_in_group("cards_in_hand")
		total_damage = base_damage + round(live_cards.size() * scaling_per_card)

	var modified_dmg := total_damage
	if enemy and enemy.modifier_handler:
		modified_dmg = enemy.modifier_handler.get_modified_value(total_damage, Modifier.Type.DMG_DEALT)
	
	if intent:
		intent.current_text = intent.base_text % modified_dmg
		
	if enemy and enemy.intent_ui and not enemy.is_acting:
		enemy.intent_ui.update_intent(intent)

func perform_action() -> void:
	if not enemy or not target:
		return
	
	# Use the locked snapshot for the actual damage dealt
	var final_damage = base_damage + round(recorded_hand_size * scaling_per_card)
	var modified_damage = final_damage
	
	if enemy.modifier_handler:
		modified_damage = enemy.modifier_handler.get_modified_value(final_damage, Modifier.Type.DMG_DEALT)
	
	var tween := create_tween().set_trans(Tween.TRANS_QUINT)
	var start := enemy.global_position
	var end := target.global_position + Vector2.RIGHT * 32
	
	var damage_effect := DamageEffect.new()
	damage_effect.amount = modified_damage
	damage_effect.sound = sound
	var target_array: Array[Node] = [target]
	
	tween.tween_property(enemy, "global_position", end, 0.4)
	tween.tween_callback(damage_effect.execute.bind(target_array))
	tween.tween_interval(0.25)
	tween.tween_property(enemy, "global_position", start, 0.4)
	
	tween.finished.connect(
		func():
			is_locked_for_attack = false 
			Events.enemy_action_completed.emit(enemy)
	)
