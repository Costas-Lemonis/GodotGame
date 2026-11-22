
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Battery settings
const MAX_BATTERY = 100.0
const BATTERY_DRAIN = 2.0

var battery = MAX_BATTERY
var frozen_enemies: Array[Node2D] = []

# Keys
var collected_keys: Array[String] = []

# Interaction
var nearby_interactables: Array[Area2D] = []

# Inventory
var inventory_items: Array[String] = []

# Hiding
var is_hidden = false
var current_hiding_spot: Area2D = null

@onready var flashlight_pivot = $FlashlightPivot
@onready var flashlight = $FlashlightPivot/Flashlight
@onready var detection_area = $FlashlightPivot/DetectionArea
@onready var battery_bar = $BatteryUI/TextureProgressBar

@onready var interaction_area = $InteractionArea
@onready var interaction_label = $InteractionUI/Label

@onready var items_container = $InventoryUI/Panel/ItemsContainer

@onready var player_sprite = $AnimatedSprite2D
@onready var player_collision = $CollisionShape2D


func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)

	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)

	battery_bar.value = battery
	interaction_label.hide()

	set_flashlight_active(false)
	update_inventory()


func _process(delta: float) -> void:
	# Flashlight follows mouse
	flashlight_pivot.look_at(get_global_mouse_position())

	# Battery drain
	if flashlight.visible:
		battery -= BATTERY_DRAIN * delta
		battery = maxf(battery, 0.0)
		battery_bar.value = battery

		# Battery empty
		if battery <= 0.0:
			set_flashlight_active(false)
			print("Battery Empty!")

	# Update interaction prompt
	update_interaction_prompt()


func _unhandled_input(event: InputEvent) -> void:
	# Toggle flashlight
	if event.is_action_pressed("flashlight") and not is_hidden:
		if flashlight.visible:
			set_flashlight_active(false)
		elif battery > 0.0:
			set_flashlight_active(true)

	# Interact / Exit hiding
	if event.is_action_pressed("interact"):
		if is_hidden:
			exit_hiding()
		else:
			interact_with_nearest()


func _physics_process(delta: float) -> void:
	# Stop movement while hiding
	if is_hidden:
		velocity = Vector2.ZERO
		return

	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()


# -------------------------
# FLASHLIGHT
# -------------------------

func set_flashlight_active(active: bool) -> void:
	flashlight.visible = active
	detection_area.monitoring = active

	# Unfreeze enemies when flashlight turns off
	if not active:
		for enemy in frozen_enemies:
			if is_instance_valid(enemy):
				enemy.set_frozen(false)

		frozen_enemies.clear()


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body not in frozen_enemies:
			frozen_enemies.append(body)
			body.set_frozen(true)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.set_frozen(false)
		frozen_enemies.erase(body)


# -------------------------
# BATTERY
# -------------------------

func recharge_battery(amount: float) -> void:
	battery = minf(battery + amount, MAX_BATTERY)
	battery_bar.value = battery


# -------------------------
# KEYS
# -------------------------

func collect_key(key_id: String) -> void:
	if key_id not in collected_keys:
		collected_keys.append(key_id)
		print("Collected key: ", key_id)


func has_key(key_id: String) -> bool:
	return key_id in collected_keys


# -------------------------
# INTERACTION SYSTEM
# -------------------------

func _on_interaction_area_entered(area: Area2D) -> void:
	if area.is_in_group("interactables"):
		if area not in nearby_interactables:
			nearby_interactables.append(area)


func _on_interaction_area_exited(area: Area2D) -> void:
	nearby_interactables.erase(area)


func interact_with_nearest() -> void:
	var nearest_object: Area2D = null
	var nearest_distance = INF

	for object in nearby_interactables:
		if not is_instance_valid(object):
			continue

		var distance = global_position.distance_to(object.global_position)

		if distance < nearest_distance:
			nearest_distance = distance
			nearest_object = object

	if nearest_object != null and nearest_object.has_method("interact"):
		nearest_object.interact(self)


func update_interaction_prompt() -> void:
	if is_hidden:
		interaction_label.hide()
		return

	var has_nearby_object = false

	for object in nearby_interactables:
		if is_instance_valid(object):
			has_nearby_object = true
			break

	interaction_label.visible = has_nearby_object


# -------------------------
# INVENTORY SYSTEM
# -------------------------

func add_inventory_item(item_id: String) -> void:
	if item_id not in inventory_items:
		inventory_items.append(item_id)
		update_inventory()


func remove_inventory_item(item_id: String) -> void:
	if item_id in inventory_items:
		inventory_items.erase(item_id)

	if item_id in collected_keys:
		collected_keys.erase(item_id)

	update_inventory()


func update_inventory() -> void:
	for child in items_container.get_children():
		child.queue_free()

	for item_id in inventory_items:
		var item_label = Label.new()

		item_label.text = get_item_name(item_id)
		item_label.add_theme_font_size_override("font_size", 18)

		items_container.add_child(item_label)


func get_item_name(item_id: String) -> String:
	match item_id:
		"red_key":
			return "Red Key"

		"blue_key":
			return "Blue Key"

		"green_key":
			return "Green Key"

		"fuse":
			return "Fuse"

		_:
			return item_id


# -------------------------
# HIDING SYSTEM
# -------------------------

func enter_hiding(hiding_spot: Area2D) -> void:
	if is_hidden:
		return

	is_hidden = true
	current_hiding_spot = hiding_spot

	# Stop player movement
	velocity = Vector2.ZERO

	# Turn off flashlight
	set_flashlight_active(false)

	# Move player inside hiding spot
	global_position = hiding_spot.get_node("HidePosition").global_position

	# Hide player sprite
	player_sprite.hide()

	# Disable player collision
	player_collision.set_deferred("disabled", true)

	# Disable interaction detection
	interaction_area.set_deferred("monitoring", false)

	# Clear nearby interactables
	nearby_interactables.clear()

	interaction_label.hide()

	print("Player is hiding!")


func exit_hiding() -> void:
	if not is_hidden:
		return

	if not is_instance_valid(current_hiding_spot):
		is_hidden = false
		player_sprite.show()
		player_collision.set_deferred("disabled", false)
		interaction_area.set_deferred("monitoring", true)
		return

	# Move player outside hiding spot
	global_position = current_hiding_spot.get_node("ExitPosition").global_position

	# Show player
	player_sprite.show()

	# Restore collision
	player_collision.set_deferred("disabled", false)

	# Restore interaction detection
	interaction_area.set_deferred("monitoring", true)

	current_hiding_spot = null
	is_hidden = false

	print("Player exited hiding spot!")
