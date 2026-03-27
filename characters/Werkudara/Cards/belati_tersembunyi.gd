extends Card

var _last_execution_frame: int = -1

@export var base_damage := 4
@export var base_poison := 2

@export var poison_status: Status 

func get_default_tooltip() -> String:
	return tooltip_text % base_damage

func apply_effects(targets: Array[Node], modifiers: ModifierHandler) -> void:
	var current_frame = Engine.get_process_frames()
	if current_frame == _last_execution_frame:
		return
	_last_execution_frame = current_frame

	var actual_damage = modifiers.get_modified_value(base_damage, Modifier.Type.DMG_DEALT)
	var damage_effect := DamageEffect.new()
	damage_effect.amount = actual_damage
	damage_effect.sound = sound
	damage_effect.execute(targets)
	
	for target in targets:
		if not is_instance_valid(target):
			continue
			
		if target.get("status_handler") and poison_status:
			var status_to_apply = poison_status.duplicate()
			status_to_apply.stacks = base_poison
			target.status_handler.add_status(status_to_apply)
