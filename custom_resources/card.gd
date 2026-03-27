class_name Card
extends Resource

enum Type {ATTACK, SKILL, POWER}
enum Target {SELF, SINGLE_ENEMY, ALL_ENEMIES, EVERYONE}
enum Rarity {COMMON, RARE, SUPER_RARE, DEBUFF}

const RARITY_COLORS := {
	Rarity.COMMON: Color.DIM_GRAY,
	Rarity.RARE: Color.BLUE_VIOLET,
	Rarity.SUPER_RARE: Color.GOLDENROD,
	Rarity.DEBUFF: Color.MEDIUM_SEA_GREEN
}

@export_group("Card Attributes")
@export var id: String
@export var rarity: Rarity
@export var type: Type
@export var target : Target
@export var cost: int
@export var exhausts: bool = false

@export_group("Card Visual")
@export var icon: Texture
@export_multiline var tooltip_text : String
@export_multiline var flavour_text : String
@export var sound: AudioStream

func is_single_targeted() -> bool:
	return target == Target.SINGLE_ENEMY

func _get_targets(targets: Array[Node]) -> Array[Node]:
	if not targets:
		return []
		
	var tree := targets[0].get_tree()
	
	match target:
		Target.SELF:
			return tree.get_nodes_in_group("player")
		Target.ALL_ENEMIES:
			return tree.get_nodes_in_group("enemies")
		Target.EVERYONE:
			return tree.get_nodes_in_group("enemies") + tree.get_nodes_in_group("player")
	
	return []
	
func play(targets: Array[Node], char_stats: CharacterStats, _modifiers: ModifierHandler) -> void:
	var tree = Engine.get_main_loop()
	var player_handler = tree.get_first_node_in_group("player_handler")
	
	var final_cost = cost
	
	var cards = tree.get_nodes_in_group("cards_in_hand")
	for c_ui in cards:
		if c_ui.get("card") == self and c_ui.get("cost_override") != null and c_ui.cost_override != -1:
			final_cost = c_ui.cost_override
			break
	
	if player_handler and player_handler.get("next_card_is_free") == true:
		final_cost = 0
		player_handler.next_card_is_free = false

	char_stats.mana -= final_cost
	
	if is_single_targeted():
		apply_effects(targets, _modifiers)
	else:
		apply_effects(_get_targets(targets), _modifiers)

	Events.card_played.emit(self)

func apply_effects(_targets: Array[Node], _modifiers: ModifierHandler) -> void:
	pass

func get_default_tooltip() -> String:
	return tooltip_text

func get_flavour_text() -> String:
	return flavour_text

func get_updated_tooltip(player_modifiers: ModifierHandler, enemy_modifiers: ModifierHandler) -> String:
	var text := tooltip_text
	var bonus := _get_global_bonus_damage()
	
	var tree = Engine.get_main_loop()
	var player_handler = tree.get_first_node_in_group("player_handler")
	var multiplier: int = 2 if (player_handler and player_handler.get("next_attack_doubled") and type == Type.ATTACK) else 1
	
	var placeholder_count = text.count("%s")
	if placeholder_count == 0: return text

	var values = []
	
	var dmg_val = get("base_damage")
	if dmg_val != null:
		var base_with_bonus = int(dmg_val) + bonus
		var modified_dmg := player_modifiers.get_modified_value(base_with_bonus, Modifier.Type.DMG_DEALT)
		modified_dmg *= multiplier
		
		if enemy_modifiers:
			modified_dmg = enemy_modifiers.get_modified_value(modified_dmg, Modifier.Type.DMG_TAKEN)
		
		var damage_string = str(modified_dmg)
		if modified_dmg > (int(dmg_val) + bonus) or multiplier > 1:
			damage_string = "[color=red]" + damage_string + "[/color]"
		values.append(damage_string)
	
	var status_val = get("base_poison")
	if status_val != null:
		values.append(str(status_val))
	
	if values.size() < placeholder_count:
		for i in range(placeholder_count - values.size()):
			values.append("??")

	return text % values.slice(0, placeholder_count)

func _get_global_bonus_damage() -> int:
	var tree = Engine.get_main_loop()
	if tree and tree.current_scene.get("stats"):
		return tree.current_scene.stats.bonus_damage
	return 0
