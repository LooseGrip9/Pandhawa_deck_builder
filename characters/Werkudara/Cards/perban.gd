#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var heal_amount := 4
@export var optional_sound: AudioStream

var _already_healed := false

func get_default_tooltip() -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _already_healed:
		return
		
	_already_healed = true
	
	for target in targets:
		var stats = target.get("stats")
		if stats:
			var old_hp = stats.health
			stats.health = min(stats.health + heal_amount, stats.max_health)
			
			print("Heal triggered! Old: %d, New: %d" % [old_hp, stats.health])
			
			if stats.has_signal("stats_changed"):
				stats.stats_changed.emit()
	
	if targets.is_empty():
		_already_healed = false
		return
		
	var tree = targets[0].get_tree()
	tree.create_timer(0.1).timeout.connect(func(): _already_healed = false)

	if optional_sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
