class_name BijaksanaStatus
extends Status

func initialize_status(_target: Node) -> void:
	status_changed.connect(_on_status_changed.bind(_target))
	_on_status_changed(_target)

func _on_status_changed(target: Node) -> void:
	pass
