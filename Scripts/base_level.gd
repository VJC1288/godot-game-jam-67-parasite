extends Node3D

class_name Level

signal level_exited(level)

@export var level_name: String
@onready var spawn_point = $SpawnPoint
@onready var exit_portal = $ExitPortal

func _ready():
	get_tree().create_timer(2.0).timeout.connect(enable_portal)

func _on_exit_portal_body_entered(body):

	if level_name != "" and body.is_in_group("player"):
		emit_signal("level_exited", level_name)

func enable_portal():
	exit_portal.monitoring = true
