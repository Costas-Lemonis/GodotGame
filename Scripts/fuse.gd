extends Area2D

func interact(player: Node2D) -> void:
	player.add_inventory_item("fuse")
	queue_free()
