extends Node3D


const LEVEL_1 = preload("res://Scenes/Levels/level_1.tscn")
const LEVEL_2 = preload("res://Scenes/Levels/level_2.tscn")

var current_level: Level = null

var player: Player

func initialize(passed_player):
	player = passed_player
	switch_level("test_level")
	
func switch_level(from_level: String):
	if current_level != null:
		current_level.queue_free()
	
	player.set_state(1)

	var next_level_scene
	match from_level:
		"test_level":
			next_level_scene = LEVEL_1
		"level1":
			next_level_scene = LEVEL_2
		_:
			next_level_scene = LEVEL_1
	
	var next_level = next_level_scene.instantiate()
	next_level.level_exited.connect(switch_level)
	add_child(next_level)
	player.global_position = next_level.spawn_point.global_position
	current_level = next_level

	
