extends Card

func is_playable(_hand: Node) -> bool:
	return false 

func play(_targets: Array[Node], _char_stats: CharacterStats, _modifiers: ModifierHandler) -> void:
	pass
