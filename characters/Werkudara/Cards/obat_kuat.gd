extends Card

const KYAT_STATUS = preload("res://statuses/kyat.tres")

@export var optional_sound: AudioStream

func apply_effects(targets: Array[Node]) -> void:
	var status_effect := StatusEffect.new()
	var obat_kuat := KYAT_STATUS.duplicate()
	status_effect.status = obat_kuat
	status_effect.execute(targets)
