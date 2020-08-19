extends KinematicBody2D

export var max_velocity: int = 150 # pixels per second
export var time_to_full_speed: float = .3 # seconds
export var time_to_full_stop: float = .3 # seconds
export var roll_speed_modifier: float = 1.5

enum {
	MOVE,
	ROLL,
	ATTACK
}

var state = MOVE
var current_velocity = Vector2.ZERO
var roll_direction = current_velocity
var stats = PlayerStats

onready var animation_player = $AnimationPlayer
onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get('parameters/playback')
onready var sword_hitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox

func _ready():
	animation_tree.active = true
	stats.connect('no_health', self, 'queue_free')

func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			update_facing_direction()
			handle_movement_animation()
			handle_running_movement(delta)
		ATTACK:
			handle_attack_animation()
		ROLL:
			handle_roll_animation()
			handle_roll_movement(delta)
			
	if Input.is_action_just_pressed("attack"):
		handle_attack()
			
	if Input.is_action_just_pressed("roll"):
		handle_roll()
	
func handle_running_movement(delta: float) -> void:
	var input_vector = get_input_vector()

	var acceleration = max_velocity / time_to_full_speed * delta
	var friction  = max_velocity / time_to_full_stop * delta

	var target_velocity = input_vector * max_velocity
	var delta_v = acceleration if target_velocity > current_velocity else friction

	var new_velocity = current_velocity.move_toward(target_velocity, delta_v)

	current_velocity = move_and_slide(new_velocity)
	
func handle_roll_movement(_delta: float) -> void:
	current_velocity = move_and_slide(roll_direction * max_velocity * roll_speed_modifier)
	
func handle_roll() -> void:
	var input_vector = get_input_vector()
	
	if input_vector != Vector2.ZERO:
		roll_direction = input_vector
		state = ROLL
	
func handle_attack() -> void:
	state = ATTACK
	
func handle_movement_animation() -> void:
	var input_vector = get_input_vector()

	if input_vector != Vector2.ZERO:
		animation_state.travel('Run')
	else:
		animation_state.travel('Idle')
	
func handle_roll_animation() -> void:
	animation_state.travel("Roll")

func handle_attack_animation() -> void:
	current_velocity = Vector2.ZERO
	animation_state.travel("Attack")

func on_attack_finished() -> void:
	state = MOVE

func on_roll_finished() -> void:
	var input_vector = get_input_vector()
	current_velocity = move_and_slide(input_vector * max_velocity)
	state = MOVE
		
func update_facing_direction() -> void:
	var input_vector = get_input_vector()
	if input_vector == Vector2.ZERO:
		return

	animation_tree.set('parameters/Idle/blend_position', input_vector)
	animation_tree.set('parameters/Run/blend_position', input_vector)
	animation_tree.set('parameters/Attack/blend_position', input_vector)
	animation_tree.set('parameters/Roll/blend_position', input_vector)

	sword_hitbox.knockback_vector = input_vector

func get_input_vector() -> Vector2:
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	return input_vector.normalized()
	
func _on_Hurtbox_area_entered(_area):
	stats.health -= 1
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect()


func _on_Hurtbox_area_exited(_area):
	pass
