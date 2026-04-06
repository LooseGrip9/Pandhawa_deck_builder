extends Card

const KEKUATAN_STATUS = preload("res://statuses/kekuatan.tres")

@export var optional_sound: AudioStream

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	print("Playing Kekuatan Card on: ", targets)
	var status_effect := StatusEffect.new()
	var kekuatan := KEKUATAN_STATUS.duplicate()
	status_effect.status = kekuatan
	status_effect.execute(targets)

	if optional_sound and targets.size() > 0:
		var tree = targets[0].get_tree()
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = optional_sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
