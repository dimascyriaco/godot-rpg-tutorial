extends KinematicBody2D

export var knockback_amount = 200
export var friction = 100
export var max_speed = 50
export var acceleration = 500

enum State {
	IDLE,
	WANDER,
	CHASE
}

var current_velocity = Vector2.ZERO
var knockback = Vector2.ZERO

var current_state = State.IDLE

onready var stats = $Stats
onready var player_detection_zone = $PlayerDetectionZone
onready var sprite = $AnimatedSprite
onready var hurtbox = $Hurtbox
onready var soft_collision = $SoftCollision
onready var wander_controller = $WanderController

var DeathAnimation = preload('res://Components/Enemies/Bat/BatDeathAnimation.tscn')

func _ready():
	randomize()
	current_state = pick_random_state([State.IDLE, State.WANDER])

func _physics_process(delta) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, friction * delta)
	knockback = move_and_slide(knockback)

	match current_state:
		State.IDLE:
			handle_idle(delta)
		State.WANDER:
			handle_wander(delta)
		State.CHASE:
			handle_chase(delta)
			handle_animation()

	if soft_collision.is_colliding():
		current_velocity += soft_collision.get_push_vector() * delta * 400

	current_velocity = move_and_slide(current_velocity)

func handle_animation() -> void:
	sprite.flip_h = current_velocity.x < 0

func handle_chase(delta: float) -> void:
	if !player_detection_zone.can_see_player():
		current_state = State.IDLE
		return
	
	var player = player_detection_zone.player
	var player_direction = global_position.direction_to(player.global_position)

	current_velocity = current_velocity.move_toward(player_direction * max_speed, acceleration * delta)

func handle_idle(delta: float) -> void:
	current_velocity = current_velocity.move_toward(Vector2.ZERO, friction * delta)

	seek_player()
	reset_wander_timer()

func handle_wander(delta: float) -> void:
	seek_player()
	reset_wander_timer()

	var player_direction = global_position.direction_to(wander_controller.target_position)
	current_velocity = current_velocity.move_toward(player_direction * max_speed, acceleration * delta)
	sprite.flip_h = current_velocity.x < 0

	if (global_position.distance_to(wander_controller.target_position)) <= max_speed:
		current_state = pick_random_state([State.WANDER, State.IDLE])
		wander_controller.start_timer(rand_range(1, 3))

func reset_wander_timer() -> void:
	if wander_controller.get_time_left() <= 0:
		current_state = pick_random_state([State.WANDER, State.IDLE])
		wander_controller.start_timer(rand_range(1, 3))

func seek_player() -> void:
	if player_detection_zone.can_see_player():
		current_state = State.CHASE

func pick_random_state(state_list: Array):
	state_list.shuffle()
	return state_list.pop_front()

func _on_Hurtbox_area_entered(hitbox):
	stats.health -= hitbox.damage
	knockback = hitbox.knockback_vector * knockback_amount
	hurtbox.create_hit_effect()

func _on_Stats_no_health():
	var death_animation = DeathAnimation.instance()
	death_animation.position = self.position

	get_parent().add_child(death_animation)

	queue_free()
