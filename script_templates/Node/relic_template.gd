extends Relic

var member_var := 0

func initialize_relic(_owner: RelicUI) -> void:
	print("happens once when we gain new relic")

func activate_relic(_owner: RelicUI) -> void:
	print("happens at a specific times based on the Relic.Type property")

func deactivate_relic(_owner: RelicUI) -> void:
	print("called when RelicUI is exiting SceeTree (deleted)")
	print("event based relic should be disconnected from the EventBus here")

func get_tooltip() -> String:
	return tooltip
