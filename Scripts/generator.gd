
extends Area2D

var is_activated = false
var message_active = false

@onready var status_label = $StatusLabel

# Light flickering settings
var flicker_timer = 0.0
var flicker_interval = 0.08
var lights: Array[Light2D] = []


func _ready() -> void:
	status_label.hide()

	# Get all generator lights
	for light in get_tree().get_nodes_in_group("generator_lights"):
		if light is Light2D:
			lights.append(light)
			light.enabled = false


func _process(delta: float) -> void:
	if is_activated:
		flicker_timer += delta

		if flicker_timer >= flicker_interval:
			flicker_timer = 0.0
			flicker_lights()


func interact(player: Node2D) -> void:
	if is_activated:
		return

	if "fuse" in player.inventory_items:
		player.remove_inventory_item("fuse")
		activate_generator()
	else:
		show_missing_fuse_message()


func show_missing_fuse_message() -> void:
	if message_active:
		return

	message_active = true
	status_label.text = "FUSE REQUIRED"
	status_label.show()

	await get_tree().create_timer(2.0).timeout

	status_label.hide()
	message_active = false


func activate_generator() -> void:
	is_activated = true

	# Enable all lights
	for light in lights:
		light.enabled = true

	status_label.text = "GENERATOR ACTIVATED"
	status_label.show()

	print("Generator Activated!")


func flicker_lights() -> void:
	for light in lights:
		# Random brightness
		light.energy = randf_range(0.3, 1.2)
