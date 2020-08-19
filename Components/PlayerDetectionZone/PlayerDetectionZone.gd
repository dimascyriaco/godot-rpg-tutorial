extends Area2D

var player = null

func can_see_player() -> bool:
	return player != null

func _on_PlayerDetectionZone_body_entered(body):
	print('Detected player')
	player = body

func _on_PlayerDetectionZone_body_exited(_body):
	print('Lost player')
	player = null
