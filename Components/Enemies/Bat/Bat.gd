extends KinematicBody2D

export var knockback_amount = 100

var knockback = Vector2.ZERO

onready var stats = $Stats

func _physics_process(delta) -> void:
	knockback = knockback.move_toward(Vector2.ZERO, 200 * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(hitbox):
	stats.health -= hitbox.damage
	knockback = hitbox.knockback_vector * knockback_amount

func _on_Stats_no_health():
	queue_free()
