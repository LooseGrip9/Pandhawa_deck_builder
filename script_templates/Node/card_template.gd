#meta-name: Card Logic
#meta-description : What happens when a card is played

class_name StatusTemplate
extends Status

var member_var := 0

@export var optional_sound: AudioStream

func initialize_status(_target: Node) -> void:
	print("initialize status for target %s" % _target)
	

func apply_status(_target: Node) -> void:
	print("apply status to target : %s" % _target)
	print("apply status to target : %s" % member_var)
	
	status_applied.emit(self)
