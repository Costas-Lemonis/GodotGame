
extends CharacterBody2D

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@onready var flashlight_pivot = $FlashlightPivot
@onready var flashlight = $FlashlightPivot/Flashlight
@onready var detection_area = $FlashlightPivot/DetectionArea


func _ready() -> void:
	flashlight.visible = false
	detection_area.monitoring = false

	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)


func _process(delta: float) -> void:
	# Ο φακός ακολουθεί το ποντίκι
	flashlight_pivot.look_at(get_global_mouse_position())


func _unhandled_input(event: InputEvent) -> void:
	# Ενεργοποίηση / απενεργοποίηση φακού
	if event.is_action_pressed("flashlight"):
		flashlight.visible = not flashlight.visible
		detection_area.monitoring = flashlight.visible


func _on_detection_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.set_frozen(true)


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body.set_frozen(false)


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
