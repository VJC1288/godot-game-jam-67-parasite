extends Node3D

@onready var music = $Music
@onready var level_manager = $LevelManager
const SLUGGY = preload("res://Scenes/sluggy.tscn")

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	spawn_player()
	level_manager.initialize(player)

func _input(event):
	if event is InputEventKey:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
	if Input.is_action_just_pressed("restart_level") and level_manager.current_level != null:
		level_manager.player.die()
		level_manager.restart_level()

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
	level_manager.restart_level()

func _process(delta):
	if !music.playing:
		music.play()
