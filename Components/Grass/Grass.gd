extends Node2D

var GrassEffect = preload("res://Components/Grass/GrassEffect.tscn")

func _on_Hurtbox_area_entered(_area):
	var grass_effect = GrassEffect.instance()
	grass_effect.position = self.position

	get_parent().add_child(grass_effect)

	queue_free()
