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


func deal_damage(entity: CharacterBody3D):
	pass

func set_team_enemy():
	team = TeamEnum.ENEMY
	
func set_team_player():
	team = TeamEnum.PlAYER
