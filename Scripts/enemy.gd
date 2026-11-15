
extends CharacterBody2D

const SPEED = 80.0

var is_frozen = false
var direction = -1


func _physics_process(delta: float) -> void:

	# Αν ο εχθρός φωτίζεται, σταματάει
	if is_frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Κανονική κίνηση
	velocity.x = direction * SPEED

	move_and_slide()


func set_frozen(value: bool) -> void:
	is_frozen = value

	if is_frozen:
		velocity = Vector2.ZERO
