class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN

func execute(targets : Array[Node]) -> void:
	var bonus_damage := 0
	var tree = Engine.get_main_loop()
	var player_handler = tree.get_first_node_in_group("player_handler")
	var is_doubled = player_handler and player_handler.get("next_attack_doubled")
	
	if not targets.is_empty() and targets[0]:
		var main_scene = targets[0].get_tree().current_scene
		if "stats" in main_scene and main_scene.get("stats") != null:
			var run_stats = main_scene.get("stats")
			if "bonus_damage" in run_stats:
				bonus_damage = run_stats.bonus_damage

	for target in targets:
		if not target: continue
			
		if target is Enemy or target is Player:
			var final_damage = amount
			if target is Enemy:
				final_damage += bonus_damage
			
			if is_doubled:
				final_damage *= 2
				print("EFFECT: Multiplier applied! Final: ", final_damage)
				
			target.take_damage(final_damage, receiver_modifier_type)
			SFXPlayer.play(sound)
