extends Node3D

const LEVEL_1 = preload("res://Scenes/Levels/level_1.tscn")
const LEVEL_2 = preload("res://Scenes/Levels/level_2.tscn")
const LEVEL_3 = preload("res://Scenes/Levels/level_3.tscn")
const LEVEL_4 = preload("res://Scenes/Levels/level_4.tscn")
const LEVEL_5 = preload("res://Scenes/Levels/level_5.tscn")
const LEVEL_6 = preload("res://Scenes/Levels/level_6.tscn")
const LEVEL_7 = preload("res://Scenes/Levels/level_7.tscn")
const LEVEL_8 = preload("res://Scenes/Levels/level_8.tscn")

@export var starting_level: int = 1

#keep level 1 last for now until an end screen is set. this will cause game to loop back to level 1
var level_array = [null, LEVEL_1, LEVEL_2, LEVEL_3, LEVEL_4, LEVEL_5, LEVEL_6, LEVEL_7, LEVEL_8]

var current_level: Level = null


var player: Player

func initialize(passed_player):
	player = passed_player
	switch_level(starting_level-1)

func reset_player(passed_player):
	player = passed_player

func restart_level():
	
	#set state to idle to make sure player doesn't stick to a mind controlled enemy
	player.set_state(1)
	
	var level_number
	if current_level != null:
		level_number = current_level.level_number
		current_level.queue_free()
	
	var next_level_scene = level_array[level_number]
	var next_level = next_level_scene.instantiate()
	next_level.level_exited.connect(switch_level)
	add_child(next_level)
	player.health_component.set_health_to(100)
	player.global_position = next_level.spawn_point.global_position
	current_level = next_level

func switch_level(from_level: int):
	
	#set state to idle to make sure player doesn't stick to a mind controlled enemy
	player.set_state(1)
	
	if current_level != null:
		current_level.queue_free()
		
	if from_level == (level_array.size() - 1):
		get_tree().change_scene_to_packed(Globals.GAME_OVER_SCREEN)
	else:
		var next_level_scene = level_array[from_level+1]
		var next_level = next_level_scene.instantiate()
		next_level.level_exited.connect(switch_level)
		add_child(next_level)
		player.global_position = next_level.spawn_point.global_position
		player.health_component.set_health_to(100)
		current_level = next_level

func get_current_spawn_location() -> Vector3:
	return current_level.spawn_point.global_position
