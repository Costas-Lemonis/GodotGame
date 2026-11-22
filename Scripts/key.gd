extends Area2D

@export var key_id: String = "red_key"

func interact(player: Node2D) -> void:
	player.collect_key(key_id)
	player.add_inventory_item(key_id)
	queue_free()
