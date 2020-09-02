extends Node2D

export(int) var wander_range = 32

onready var start_position: Vector2 = global_position
onready var target_position: Vector2 = global_position

onready var timer = $Timer

func _ready() -> void:
	update_target_position()

func update_target_position() -> void:
	var target_vector = Vector2(rand_range(-wander_range, wander_range), rand_range(-wander_range, wander_range))
	print('target_vector', target_vector)
	target_position = start_position + target_vector

func get_time_left() -> float:
	return timer.time_left

func start_timer(duration: int) -> void:
	timer.start(duration)

func _on_Timer_timeout():
	update_target_position()
