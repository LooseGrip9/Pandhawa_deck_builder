class_name DrawEffect
extends Effect

var amount := 0

func execute(targets: Array[Node]) -> void:
	if targets.is_empty():
		return
		
	# Access the scene tree through a target node
	var tree := targets[0].get_tree()
	
	# Find your PlayerHandler node (Make sure it's in the "player_handler" group!)
	var handler = tree.get_first_node_in_group("player_handler") as PlayerHandler
	
	if handler:
		handler.draw_cards(amount)
