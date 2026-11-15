
extends Area2D

const BATTERY_AMOUNT = 30.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.recharge_battery(BATTERY_AMOUNT)
		queue_free()
