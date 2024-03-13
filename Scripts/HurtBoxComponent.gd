extends Area3D

class_name HurtBoxComponent

enum TeamEnum {PlAYER = 1, ENEMY}

@export var damage: int
@export var team: TeamEnum

var actor

func _ready():
	actor = get_parent()


func _on_area_entered(area):

	if area.has_method("take_damage"):
		if area.team != team:
			area.take_damage(damage, global_position)


func setTeamEnemy():
	team = TeamEnum.ENEMY
	
func setTeamPlayer():
	team = TeamEnum.PlAYER
