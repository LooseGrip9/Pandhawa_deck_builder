class_name StatusJerat
extends Status

@export var target_type: int = 0 

func _init() -> void:
	id = "jerat_sengkuni"

func get_extra_cost(card: Card) -> int:
	# If this card type matches Sengkuni's trap type, return the tax
	if target_type == 0 and card.type == Card.Type.ATTACK:
		return stacks
	
	if target_type == 1 and card.type == Card.Type.SKILL:
		return stacks
		
	return 0

func get_tooltip() -> String:
	var type_str = "Serangan" if target_type == 0 else "Skill"
	return "Jerat Sengkuni: Kartu %s butuh +%d Mana." % [type_str, stacks]
