#meta-name: Card Logic
#meta-description : What happens when a card is played

extends Card

@export var optional_sound: AudioStream

func apply_effects(_targets: Array[Node], modifiers: ModifierHandler) -> void:
	print("card played")
	print("target %s" % _targets)
