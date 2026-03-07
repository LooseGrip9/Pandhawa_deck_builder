class_name DrawingStatus
extends Status

func on_status_applied(_owner: Node) -> void:
	if _owner.has_signal("damaged"):
		_owner.damaged.connect(_on_owner_damaged)

func _on_owner_damaged(_amount: int) -> void:
	stacks = 0
	status_changed.emit()
