class_name DrawEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
		
	var tree := targets[0].get_tree()
	
	var handler = tree.get_first_node_in_group("player_handler") as PlayerHandler
	
	if handler:
		handler.draw_cards(amount)
