extends Node3D

@onready var level_manager = $LevelManager
const SLUGGY = preload("res://Scenes/sluggy.tscn")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	spawn_player()
	level_manager.initialize(player)

	
	
func spawn_player():
	player = SLUGGY.instantiate()
	add_child(player)
