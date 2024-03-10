extends Node3D

@onready var level_manager = $LevelManager
const SLUGGY = preload("res://Scenes/sluggy.tscn")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	level_manager.initialize(player)
	

#can combine these two functions at some point but too lazy to do it right now ^_^
func spawn_player():
	player = SLUGGY.instantiate()
	player.player_died.connect(respawn_player)
	add_child(player)

func respawn_player():
	player = SLUGGY.instantiate()
	player.player_died.connect(respawn_player)
	player.position = level_manager.get_current_spawn_location()
	level_manager.reset_player(player)
	add_child(player)
