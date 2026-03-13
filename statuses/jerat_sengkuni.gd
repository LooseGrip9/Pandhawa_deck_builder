class_name StatusJeratSengkuni
extends Status

enum SnareType { ATTACK, SKILL }
@export var snare_target: SnareType = SnareType.ATTACK

func get_extra_cost(card: Card) -> int:
	if snare_target == SnareType.ATTACK and card.type == Card.Type.ATTACK:
		return stacks
	if snare_target == SnareType.SKILL and card.type == Card.Type.SKILL:
		return stacks
	return 0

func get_tooltip() -> String:
	var target_name = "Serangan" if snare_target == SnareType.ATTACK else "Skill"
	return "Jerat Sengkuni: Kartu %s terjerat tipu daya, butuh +%d Mana." % [target_name, stacks]
