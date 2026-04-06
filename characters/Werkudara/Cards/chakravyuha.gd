#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var block_amount := 15
@export var counter_amount := 5
@export var optional_sound: AudioStream

func get_default_tooltip() -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	for target in targets:
		var stats = target.get("stats") as Stats
		if stats:
			stats.block += block_amount
			stats.counter_damage += counter_amount
			stats.stats_changed.emit()
			
	if optional_sound and targets.size() > 0:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		targets[0].get_tree().current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
