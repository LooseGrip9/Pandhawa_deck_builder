#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var optional_sound: AudioStream

var energy_to_gain := 1

func get_default_tooltip() -> String:
	return tooltip_text

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	var tree = targets[0].get_tree() if not targets.is_empty() else null
	if not tree: return

	var handler = tree.get_first_node_in_group("player_handler") as PlayerHandler
	if handler and handler.character:
		handler.character.mana += energy_to_gain
		
	if optional_sound:
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
