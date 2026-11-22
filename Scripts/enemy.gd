
extends CharacterBody2D

@export var left_point: Marker2D
@export var right_point: Marker2D

const PATROL_SPEED = 80.0
const CHASE_SPEED = 130.0

const DETECTION_RANGE = 180.0
const LOSE_RANGE = 280.0

const SEARCH_TIME = 3.0
const SEARCH_ARRIVAL_DISTANCE = 8.0

var is_frozen = false
var direction = -1

var player: Node2D = null

var last_player_position = Vector2.ZERO
var search_timer = 0.0

enum EnemyState {
	PATROL,
	CHASE,
	SEARCH
}

var current_state = EnemyState.PATROL


func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _physics_process(delta: float) -> void:

	# Αν φωτίζεται από τον φακό, παγώνει
	if is_frozen:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	if not is_instance_valid(player):
		velocity = Vector2.ZERO
		move_and_slide()
		return

	# Αν ο Player κρύβεται
	if player.is_hidden:
		if current_state != EnemyState.SEARCH and current_state != EnemyState.PATROL:
			last_player_position = player.global_position
			current_state = EnemyState.SEARCH
			search_timer = 0.0

	else:
		var distance = global_position.distance_to(player.global_position)

		# Έλεγχος εντοπισμού
		if current_state == EnemyState.PATROL:
			if distance <= DETECTION_RANGE:
				current_state = EnemyState.CHASE

		# Κυνήγι
		elif current_state == EnemyState.CHASE:
			last_player_position = player.global_position

			if distance >= LOSE_RANGE:
				current_state = EnemyState.SEARCH
				search_timer = 0.0

		# Αν εντοπίσει ξανά τον παίκτη
		elif current_state == EnemyState.SEARCH:
			if distance <= DETECTION_RANGE:
				current_state = EnemyState.CHASE

	# Συμπεριφορά ανά κατάσταση
	match current_state:

		EnemyState.PATROL:

			if left_point != null and right_point != null:

				var left_limit = left_point.global_position.x
				var right_limit = right_point.global_position.x

				# Έφτασε στο αριστερό όριο
				if global_position.x <= left_limit:
					direction = 1

				# Έφτασε στο δεξί όριο
				elif global_position.x >= right_limit:
					direction = -1

			velocity.x = direction * PATROL_SPEED

		EnemyState.CHASE:
			if not player.is_hidden:
				direction = sign(player.global_position.x - global_position.x)
				velocity.x = direction * CHASE_SPEED

		EnemyState.SEARCH:
			velocity.x = 0.0

			search_timer += delta

			if search_timer >= SEARCH_TIME:
				current_state = EnemyState.PATROL
				search_timer = 0.0

	move_and_slide()


func set_frozen(value: bool) -> void:
	is_frozen = value

	if is_frozen:
		velocity = Vector2.ZERO
