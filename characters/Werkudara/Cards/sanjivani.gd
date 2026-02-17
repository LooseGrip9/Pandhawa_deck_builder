extends Card

var _has_triggered := false

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _has_triggered:
		return
	
	_has_triggered = true
	
	var tree := Engine.get_main_loop() as SceneTree
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	if not player_handler:
		return
		
	var stats = player_handler.character
	
	var missing_health = stats.max_health - stats.health
	if missing_health > 0:
		stats.heal(missing_health)
	
	var reduction_amount = 10
	stats.max_health = max(1, stats.max_health - reduction_amount)
	
	if stats.health > stats.max_health:
		stats.health = stats.max_health
	
	stats.stats_changed.emit()
	
	tree.create_timer(0.2).timeout.connect(func(): _has_triggered = false)
