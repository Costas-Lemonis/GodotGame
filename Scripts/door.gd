extends Area2D

@export var required_key_id: String = "red_key"

var is_open = false
var locked_message_active = false

@onready var door_sprite = $Sprite2D
@onready var door_collision = $StaticBody2D/CollisionShape2D
@onready var interaction_collision = $CollisionShape2D
@onready var locked_label = $LockedLabel


func _ready() -> void:
	locked_label.hide()


func interact(player: Node2D) -> void:
	if is_open:
		return

	if player.has_key(required_key_id):
		player.remove_inventory_item(required_key_id)
		open_door()
	else:
		show_locked_message()


func show_locked_message() -> void:
	if locked_message_active:
		return

	locked_message_active = true
	locked_label.show()

	await get_tree().create_timer(2.0).timeout

	locked_label.hide()
	locked_message_active = false


func open_door() -> void:
	is_open = true
	door_sprite.hide()
	door_collision.set_deferred("disabled", true)
	interaction_collision.set_deferred("disabled", true)
	locked_label.hide()

	print("Door opened!")
