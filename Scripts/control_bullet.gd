extends Area3D

signal hit_enemy(enemy: Enemy)

@export var SPEED = 10.0
@export var bullet_lifetime = 0.2




# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().create_timer(bullet_lifetime).timeout.connect(remove_bullet)

func _process(delta):
	position += transform.basis * Vector3(0,0, -SPEED * delta)

	
func remove_bullet():
	call_deferred("queue_free")


func _on_body_entered(body):
	if body.is_in_group("enemies") and body.has_method("take_control"):
		emit_signal("hit_enemy", body)
