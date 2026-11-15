
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

# Battery settings
const MAX_BATTERY = 100.0
const BATTERY_DRAIN = 2.0

var battery = MAX_BATTERY
var frozen_enemies: Array[Node2D] = []

@onready var flashlight_pivot = $FlashlightPivot
@onready var flashlight = $FlashlightPivot/Flashlight
@onready var detection_area = $FlashlightPivot/DetectionArea
@onready var battery_bar = $BatteryUI/TextureProgressBar

func _ready() -> void:
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	battery_bar.value = battery
	
	set_flashlight_active(false)


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


func _unhandled_input(event: InputEvent) -> void:
	# Toggle flashlight
	if event.is_action_pressed("flashlight"):
		if flashlight.visible:
			set_flashlight_active(false)
		elif battery > 0.0:
			set_flashlight_active(true)


func set_flashlight_active(active: bool) -> void:
	flashlight.visible = active
	detection_area.monitoring = active

	# Unfreeze enemies when flashlight turns off
	if not active:
		for enemy in frozen_enemies:
			if is_instance_valid(enemy):
				enemy.set_frozen(false)

		frozen_enemies.clear()

func recharge_battery(amount: float) -> void:
	battery = minf(battery + amount, MAX_BATTERY)
	battery_bar.value = battery
	
	
func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		if body not in frozen_enemies:
			frozen_enemies.append(body)
			body.set_frozen(true)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.set_frozen(false)
		frozen_enemies.erase(body)


func _physics_process(delta: float) -> void:
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
