extends Node3D

class_name HealthComponent

@export var max_health: int

var current_health: int 

var actor


func _ready():
	actor = get_parent()
	current_health = max_health


func set_health_to(value: int):
	current_health = value
	
func heal_by_amount(amount: int):
	current_health = clamp(current_health + amount, 0, 100)
	
func damage_by_amount(amount: int):

	current_health = clamp(current_health - amount, 0, 100)
	prints("Health: ",current_health)
	if current_health <= 0:
		if actor.has_method("die"):
			actor.die()

