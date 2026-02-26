class_name DamageEffect
extends Effect

var amount := 0
var receiver_modifier_type := Modifier.Type.DMG_TAKEN

func execute(targets : Array[Node]) -> void:
	var bonus_damage := 0
	
	if not targets.is_empty() and targets[0]:
		# 1. Grab the top of the game tree directly (This is your Run node!)
		var main_scene = targets[0].get_tree().current_scene
		
		# 2. Safely check for your RunStats without triggering a circular error
		if "stats" in main_scene and main_scene.get("stats") != null:
			var run_stats = main_scene.get("stats")
			if "bonus_damage" in run_stats:
				bonus_damage = run_stats.bonus_damage

	for target in targets:
		if not target:
			continue
			
		if target is Enemy or target is Player:
			var final_damage = amount
			
			# 3. Apply the bonus damage ONLY if we are hitting an enemy
			if target is Enemy:
				final_damage += bonus_damage
				
			target.take_damage(final_damage, receiver_modifier_type)
			SFXPlayer.play(sound)
