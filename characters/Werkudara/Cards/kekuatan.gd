extends Card

const KEKUATAN_STATUS = preload("res://statuses/kekuatan.tres")

@export var optional_sound: AudioStream

func apply_effects(targets: Array[Node], _modifiers: ModifierHandler) -> void:
	print("Playing Kekuatan Card on: ", targets)
	var status_effect := StatusEffect.new()
	var kekuatan := KEKUATAN_STATUS.duplicate()
	status_effect.status = kekuatan
	status_effect.execute(targets)
