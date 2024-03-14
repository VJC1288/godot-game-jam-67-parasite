extends Area3D

signal player_in_death_zone

func _on_body_entered(body):
	if body.has_method("die"):
		body.die()
		if body.is_in_group("player"):
			emit_signal("player_in_death_zone")
