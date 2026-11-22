extends Area2D

func interact(player: Node2D) -> void:
	if player.has_method("enter_hiding"):
		player.enter_hiding(self)
