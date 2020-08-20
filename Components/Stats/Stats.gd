extends Node

export var max_health: int = 1 setget set_max_health
var health: int = max_health setget set_health

signal no_health
signal health_changed(value)
signal max_health_changed(value)

func _ready() -> void:
	health = max_health

func set_health(new_health: int) -> void:
	health = new_health

	emit_signal('health_changed', health)

	if health <= 0:
		emit_signal('no_health')

func set_max_health(new_max_health: int) -> void:
	max_health = new_max_health

	emit_signal('max_health_changed', max_health)

	if !health || health > max_health:
		self.health = max_health
