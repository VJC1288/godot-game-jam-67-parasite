extends Area3D

class_name HitBoxComponent

enum TeamEnum {PlAYER = 1, ENEMY}

@export var health_component: HealthComponent
@export var team: TeamEnum

var actor

func _ready():
	actor = get_parent()

func take_damage(amount: int, from_location: Vector3):
	health_component.damage_by_amount(amount)
	
	if actor.has_method("recoil"):
		actor.recoil(from_location)

func set_team_enemy():
	team = TeamEnum.ENEMY
	
func set_team_player():
	team = TeamEnum.PlAYER
