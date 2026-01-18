class_name Modifier
extends Node

enum Type {DMG_DEALT, CARD_COST, DMG_TAKEN, SHOP_COST, NO_MODIFIER}

@export var type: Type

func get_value(source: String) -> ModifierValue:
	for value: ModifierValue in get_children():
		if value.source == source:
			return value
	
	return null

func add_new_value(value: ModifierValue) -> void:
	var modifier_value := get_value(value.source)
	if not modifier_value:
		add_child(value)
	
	else:
		modifier_value.flat_value = value.flat_value
		modifier_value.percent_value = value.percent_value

func clear_values() -> void:
	for value: ModifierValue in get_children():
		value.queue_free()

func remove_value(source: String) -> void:
	for child in get_children():
		if child is ModifierValue and child.source == source:
			child.queue_free()
			return

func get_modified_value(base: int) -> int:
	var flat_result: int = base
	var percent_result: float = 1.0
	
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.FLAT:
			flat_result += value.flat_value
	
	for value: ModifierValue in get_children():
		if value.type == ModifierValue.Type.PERCENT_BASED:
			percent_result += value.percent_value
	
	return floori(flat_result * percent_result)
