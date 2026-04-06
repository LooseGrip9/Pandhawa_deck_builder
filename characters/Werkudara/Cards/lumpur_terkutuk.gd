extends Card

const SLOW_STATUS = preload("res://statuses/lambat.tres")

@export var slow_amount := 2
@export var optional_sound: AudioStream

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	if _targets.is_empty():
		return
	
	var slow_effect := StatusEffect.new()
	var slow := SLOW_STATUS.duplicate()
	
	slow.stacks = slow_amount 
	
	slow_effect.status = slow
	
	slow_effect.execute(_targets)
	
	if optional_sound:
		var tree = _targets[0].get_tree()
		var sfx_player = AudioStreamPlayer.new()
		sfx_player.stream = sound
		
		tree.current_scene.add_child(sfx_player) 
		sfx_player.play()
		
		sfx_player.finished.connect(sfx_player.queue_free)
