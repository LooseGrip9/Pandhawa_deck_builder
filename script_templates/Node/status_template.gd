class_name StatusTemplates
extends Status

var member_var := 0

func initialize_status(target: Node) -> void:
	print("initialize status effect : %s to target" % target)
	

func apply_status(_target: Node) -> void:
	print("My status target is %s" %_target)
	print("it does %s" % member_var)
	
	status_applied.emit(self)
